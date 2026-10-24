import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

const REGION = "asia-northeast3";
const MAX_COMMENT_LENGTH = 300;
const HIDDEN_PENDING_REVIEW = "hidden_pending_review";

type CommentCreateData = {
  workoutFinishId?: unknown;
  text?: unknown;
};

type CommentUpdateData = {
  workoutFinishId?: unknown;
  commentId?: unknown;
  text?: unknown;
};

type CommentDeleteData = {
  workoutFinishId?: unknown;
  commentId?: unknown;
};

/**
 * 전달받은 값을 필수 문자열로 검증합니다.
 *
 * @param {unknown} value 검사할 값
 * @param {string} fieldName 오류 메시지에 사용할 필드 이름
 * @return {string} 앞뒤 공백이 제거된 문자열
 */
function readRequiredString(
  value: unknown,
  fieldName: string,
): string {
  if (typeof value !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} 값이 필요합니다.`,
    );
  }

  const result = value.trim();

  if (result.length === 0) {
    throw new HttpsError(
      "invalid-argument",
      `${fieldName} 값이 비어 있습니다.`,
    );
  }

  return result;
}

/**
 * 댓글 내용을 검증합니다.
 *
 * @param {unknown} value 검사할 댓글 값
 * @return {string} 검증된 댓글 내용
 */
function readCommentText(
  value: unknown,
): string {
  const text = readRequiredString(
    value,
    "댓글",
  );

  if (text.length > MAX_COMMENT_LENGTH) {
    throw new HttpsError(
      "invalid-argument",
      `댓글은 ${MAX_COMMENT_LENGTH}자 이하로 입력해주세요.`,
    );
  }

  return text;
}

/**
 * Firestore 카운트 값을 0 이상의 정수로 변환합니다.
 *
 * @param {unknown} value 변환할 값
 * @return {number} 0 이상의 정수
 */
function readCount(
  value: unknown,
): number {
  if (
    typeof value !== "number" ||
    !Number.isFinite(value)
  ) {
    return 0;
  }

  return Math.max(
    0,
    Math.floor(value),
  );
}

/**
 * 예상하지 못한 서버 오류를 로그에 기록하고
 * 클라이언트에는 안전한 메시지를 전달합니다.
 *
 * HttpsError는 기존 오류 코드와 메시지를 유지합니다.
 *
 * @param {unknown} error 발생한 오류
 * @param {string} fallbackMessage 기본 오류 메시지
 * @throws {HttpsError} 기존 또는 변환된 Firebase Functions 오류
 */
function handleFunctionError(
  error: unknown,
  fallbackMessage: string,
): never {
  if (error instanceof HttpsError) {
    throw error;
  }

  console.error(
    fallbackMessage,
    error,
  );

  throw new HttpsError(
    "internal",
    fallbackMessage,
  );
}

/**
 * 운동 게시글 댓글을 작성합니다.
 *
 * 댓글 저장 경로:
 * workoutFinish/{workoutFinishId}/comments/{commentId}
 *
 * 알림 저장 경로:
 * users/{postOwnerUid}/notifications/{notificationId}
 */
export const feedCommentCreate = onCall(
  {
    region: REGION,
  },
  async (request) => {
    const auth = request.auth;
    const data =
      request.data as CommentCreateData;

    if (!auth) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const myUid = auth.uid;

    const workoutFinishId =
      readRequiredString(
        data?.workoutFinishId,
        "workoutFinishId",
      );

    const text = readCommentText(
      data?.text,
    );

    const workoutFinishRef = db
      .collection("workoutFinish")
      .doc(workoutFinishId);

    const userRef = db
      .collection("users")
      .doc(myUid);

    const commentRef = workoutFinishRef
      .collection("comments")
      .doc();

    try {
      const result = await db.runTransaction(
        async (transaction) => {
          /*
           * Firestore Transaction에서는
           * 모든 읽기를 쓰기보다 먼저 수행해야 합니다.
           */
          const [
            workoutFinishSnap,
            userSnap,
          ] = await Promise.all([
            transaction.get(
              workoutFinishRef,
            ),
            transaction.get(
              userRef,
            ),
          ]);

          if (!workoutFinishSnap.exists) {
            throw new HttpsError(
              "not-found",
              "댓글을 작성할 게시글을 찾을 수 없습니다.",
            );
          }

          if (!userSnap.exists) {
            throw new HttpsError(
              "not-found",
              "댓글 작성자 정보를 찾을 수 없습니다.",
            );
          }

          const workoutData =
            workoutFinishSnap.data() ?? {};

          if (
            workoutData.moderationStatus ===
            HIDDEN_PENDING_REVIEW
          ) {
            throw new HttpsError(
              "failed-precondition",
              "현재 댓글을 작성할 수 없는 게시글입니다.",
            );
          }

          const userData =
            userSnap.data() ?? {};

          const rawDisplayName =
            userData.displayName;

          const displayName =
            typeof rawDisplayName === "string" &&
            rawDisplayName.trim().length > 0 ?
              rawDisplayName.trim() :
              "사용자";

          const rawProfileImageUrl =
            userData.profileImageUrl;

          const profileImageUrl =
            typeof rawProfileImageUrl === "string" ?
              rawProfileImageUrl.trim() :
              "";

          const currentCommentsCount =
            readCount(
              workoutData.commentsCount,
            );

          const nextCommentsCount =
            currentCommentsCount + 1;

          /*
           * 게시글 작성자 UID
           */
          const postOwnerUid = String(
            workoutData.userId ?? "",
          ).trim();

          const workoutThumbnailUrl =
            String(
              workoutData.workoutThumbnailUrl ??
              "",
            ).trim();

          /*
           * 댓글 문서 생성
           */
          transaction.create(
            commentRef,
            {
              commentId: commentRef.id,
              workoutFinishId,
              userId: myUid,
              displayName,
              profileImageUrl,
              text,
              isEdited: false,

              createdAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
          );

          /*
           * 댓글 작성은 게시글 본문 수정이 아니므로
           * 게시글 updatedAt은 변경하지 않습니다.
           */
          transaction.update(
            workoutFinishRef,
            {
              commentsCount:
                nextCommentsCount,
            },
          );

          let notificationCreated = false;

          /*
           * 자신의 게시글에 직접 댓글을 작성한 경우에는
           * 알림을 생성하지 않습니다.
           */
          if (
            postOwnerUid !== "" &&
            postOwnerUid !== myUid
          ) {
            const notificationRef = db
              .collection("users")
              .doc(postOwnerUid)
              .collection("notifications")
              .doc();

            transaction.create(
              notificationRef,
              {
                /*
                 * 알림 유형
                 */
                type: "comment",

                /*
                 * 댓글 작성자 정보
                 */
                actorUid: myUid,
                actorDisplayName:
                  displayName,
                actorProfileImageUrl:
                  profileImageUrl,

                /*
                 * 알림 수신자
                 */
                recipientUid:
                  postOwnerUid,

                /*
                 * 알림 대상 게시글 및 댓글
                 */
                targetType:
                  "workoutFinish",

                targetId:
                  workoutFinishId,

                workoutFinishId,

                commentId:
                  commentRef.id,

                workoutThumbnailUrl,

                /*
                 * 시스템 푸시 알림 내용
                 */
                title:
                  "새로운 댓글",

                body:
                  `${displayName}님이 회원님의 ` +
                  "운동 기록에 댓글을 남겼습니다.",

                /*
                 * 알림 클릭 시 사용할 앱 경로
                 */
                route:
                  "/workoutFeed",

                isRead: false,
                readAt: null,

                createdAt:
                  admin.firestore
                    .FieldValue
                    .serverTimestamp(),

                updatedAt:
                  admin.firestore
                    .FieldValue
                    .serverTimestamp(),
              },
            );

            notificationCreated = true;
          }

          return {
            commentId:
              commentRef.id,

            commentsCount:
              nextCommentsCount,

            notificationCreated,
          };
        },
      );

      return {
        ok: true,
        ...result,
      };
    } catch (error) {
      handleFunctionError(
        error,
        "댓글 작성 중 오류가 발생했습니다.",
      );
    }
  },
);

/**
 * 운동 게시글 댓글을 수정합니다.
 *
 * 댓글 작성자만 수정할 수 있습니다.
 */
export const feedCommentUpdate = onCall(
  {
    region: REGION,
  },
  async (request) => {
    const auth = request.auth;
    const data =
      request.data as CommentUpdateData;

    if (!auth) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const myUid = auth.uid;

    const workoutFinishId =
      readRequiredString(
        data?.workoutFinishId,
        "workoutFinishId",
      );

    const commentId =
      readRequiredString(
        data?.commentId,
        "commentId",
      );

    const text = readCommentText(
      data?.text,
    );

    const workoutFinishRef = db
      .collection("workoutFinish")
      .doc(workoutFinishId);

    const commentRef = workoutFinishRef
      .collection("comments")
      .doc(commentId);

    try {
      await db.runTransaction(
        async (transaction) => {
          const [
            workoutFinishSnap,
            commentSnap,
          ] = await Promise.all([
            transaction.get(
              workoutFinishRef,
            ),
            transaction.get(
              commentRef,
            ),
          ]);

          if (!workoutFinishSnap.exists) {
            throw new HttpsError(
              "not-found",
              "게시글을 찾을 수 없습니다.",
            );
          }

          if (!commentSnap.exists) {
            throw new HttpsError(
              "not-found",
              "댓글을 찾을 수 없습니다.",
            );
          }

          const workoutData =
            workoutFinishSnap.data() ?? {};

          if (
            workoutData.moderationStatus ===
            HIDDEN_PENDING_REVIEW
          ) {
            throw new HttpsError(
              "failed-precondition",
              "현재 댓글을 수정할 수 없는 게시글입니다.",
            );
          }

          const commentData =
            commentSnap.data() ?? {};

          if (
            commentData.userId !== myUid
          ) {
            throw new HttpsError(
              "permission-denied",
              "본인이 작성한 댓글만 수정할 수 있습니다.",
            );
          }

          transaction.update(
            commentRef,
            {
              text,
              isEdited: true,

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
          );
        },
      );

      return {
        ok: true,
        commentId,
      };
    } catch (error) {
      handleFunctionError(
        error,
        "댓글 수정 중 오류가 발생했습니다.",
      );
    }
  },
);

/**
 * 운동 게시글 댓글을 삭제합니다.
 *
 * 댓글 작성자 또는 게시글 작성자가 삭제할 수 있습니다.
 */
export const feedCommentDelete = onCall(
  {
    region: REGION,
  },
  async (request) => {
    const auth = request.auth;
    const data =
      request.data as CommentDeleteData;

    if (!auth) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const myUid = auth.uid;

    const workoutFinishId =
      readRequiredString(
        data?.workoutFinishId,
        "workoutFinishId",
      );

    const commentId =
      readRequiredString(
        data?.commentId,
        "commentId",
      );

    const workoutFinishRef = db
      .collection("workoutFinish")
      .doc(workoutFinishId);

    const commentRef = workoutFinishRef
      .collection("comments")
      .doc(commentId);

    try {
      const result = await db.runTransaction(
        async (transaction) => {
          const [
            workoutFinishSnap,
            commentSnap,
          ] = await Promise.all([
            transaction.get(
              workoutFinishRef,
            ),
            transaction.get(
              commentRef,
            ),
          ]);

          if (!workoutFinishSnap.exists) {
            throw new HttpsError(
              "not-found",
              "게시글을 찾을 수 없습니다.",
            );
          }

          if (!commentSnap.exists) {
            throw new HttpsError(
              "not-found",
              "댓글을 찾을 수 없습니다.",
            );
          }

          const workoutData =
            workoutFinishSnap.data() ?? {};

          const commentData =
            commentSnap.data() ?? {};

          const rawPostOwnerUid =
            workoutData.userId;

          const postOwnerUid =
            typeof rawPostOwnerUid === "string" ?
              rawPostOwnerUid :
              "";

          const rawCommentOwnerUid =
            commentData.userId;

          const commentOwnerUid =
            typeof rawCommentOwnerUid === "string" ?
              rawCommentOwnerUid :
              "";

          const canDelete =
            myUid === commentOwnerUid ||
            myUid === postOwnerUid;

          if (!canDelete) {
            throw new HttpsError(
              "permission-denied",
              "이 댓글을 삭제할 권한이 없습니다.",
            );
          }

          const currentCommentsCount =
            readCount(
              workoutData.commentsCount,
            );

          const nextCommentsCount =
            Math.max(
              0,
              currentCommentsCount - 1,
            );

          transaction.delete(
            commentRef,
          );

          /*
           * 댓글 삭제는 게시글 본문 수정이 아니므로
           * 게시글 updatedAt은 변경하지 않습니다.
           */
          transaction.update(
            workoutFinishRef,
            {
              commentsCount:
                nextCommentsCount,
            },
          );

          return {
            commentsCount:
              nextCommentsCount,
          };
        },
      );

      return {
        ok: true,
        commentId,
        ...result,
      };
    } catch (error) {
      handleFunctionError(
        error,
        "댓글 삭제 중 오류가 발생했습니다.",
      );
    }
  },
);
