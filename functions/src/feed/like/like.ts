import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const feedLike = onCall(
  {
    region: "asia-northeast3",
  },
  async (request) => {
    const auth = request.auth;
    const data = request.data;

    if (!auth) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const myUid = auth.uid;

    const workoutFinishId = String(
      data?.workoutFinishId ?? "",
    ).trim();

    if (workoutFinishId === "") {
      throw new HttpsError(
        "invalid-argument",
        "유효한 workoutFinishId가 필요합니다.",
      );
    }

    const myRef = db
      .collection("users")
      .doc(myUid);

    const workoutFinishRef = db
      .collection("workoutFinish")
      .doc(workoutFinishId);

    const likeRef = workoutFinishRef
      .collection("likes")
      .doc(myUid);

    const result = await db.runTransaction(
      async (tx) => {
        /*
         * 트랜잭션의 모든 읽기를 먼저 수행
         */
        const workoutFinishDoc = await tx.get(
          workoutFinishRef,
        );

        const likeDoc = await tx.get(
          likeRef,
        );

        const myDoc = await tx.get(
          myRef,
        );

        if (!workoutFinishDoc.exists) {
          throw new HttpsError(
            "not-found",
            "운동 기록을 찾을 수 없습니다.",
          );
        }

        const workoutData =
          workoutFinishDoc.data() ?? {};

        /*
         * 운동 기록 작성자 UID
         */
        const ownerUid = String(
          workoutData.userId ?? "",
        ).trim();

        /*
         * 이미 좋아요 상태인 경우
         *
         * 기존 문서 필드만 보정하고
         * 알림은 다시 생성하지 않음
         */
        if (likeDoc.exists) {
          tx.set(
            likeRef,
            {
              uid: myUid,
              userId: myUid,
              workoutId: workoutFinishId,
              workoutFinishId,

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
            {
              merge: true,
            },
          );

          tx.update(
            workoutFinishRef,
            {
              likedByUserIds:
                admin.firestore.FieldValue
                  .arrayUnion(myUid),

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
          );

          return {
            alreadyLiked: true,
            notificationCreated: false,
          };
        }

        /*
         * 새로운 좋아요 문서 생성
         */
        tx.set(
          likeRef,
          {
            // 기존 코드 호환용
            uid: myUid,

            // 사용자 및 운동 기록 식별값
            userId: myUid,
            workoutId: workoutFinishId,
            workoutFinishId,

            likedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),

            createdAt:
              admin.firestore.FieldValue
                .serverTimestamp(),

            updatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
        );

        /*
         * 좋아요 수와 좋아요 사용자 목록 갱신
         */
        tx.update(
          workoutFinishRef,
          {
            likesCount:
              admin.firestore.FieldValue
                .increment(1),

            likedByUserIds:
              admin.firestore.FieldValue
                .arrayUnion(myUid),

            updatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
        );

        let notificationCreated = false;

        /*
         * 자신의 운동 기록에 자신이 좋아요한 경우에는
         * 알림을 생성하지 않음
         */
        if (
          ownerUid !== "" &&
          ownerUid !== myUid
        ) {
          const myData = myDoc.data() ?? {};

          const rawDisplayName = String(
            myData.displayName ?? "",
          ).trim();

          const displayName =
            rawDisplayName === "" ?
              "새로운 사용자" :
              rawDisplayName;

          const profileImageUrl = String(
            myData.profileImageUrl ?? "",
          ).trim();

          const workoutThumbnailUrl = String(
            workoutData.workoutThumbnailUrl ?? "",
          ).trim();

          const notificationRef = db
            .collection("users")
            .doc(ownerUid)
            .collection("notifications")
            .doc();

          tx.set(
            notificationRef,
            {
              /*
               * 알림 종류
               */
              type: "like",

              /*
               * 좋아요한 사용자
               */
              actorUid: myUid,
              actorDisplayName: displayName,
              actorProfileImageUrl:
                profileImageUrl,

              /*
               * 알림을 받는 운동 기록 작성자
               */
              recipientUid: ownerUid,

              /*
               * 좋아요 대상 운동 기록
               */
              targetType: "workoutFinish",
              targetId: workoutFinishId,
              workoutFinishId,

              workoutThumbnailUrl,

              /*
               * 알림 표시 문구
               */
              title: "새로운 좋아요",

              body:
                `${displayName}님이 회원님의 ` +
                "운동 기록을 좋아합니다.",

              /*
               * 현재 존재하는 피드 경로
               *
               * 운동 상세 페이지가 생기면
               * 상세 페이지 경로로 변경 가능
               */
              route: "/workoutFeed",

              isRead: false,
              readAt: null,

              createdAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
          );

          notificationCreated = true;
        }

        return {
          alreadyLiked: false,
          notificationCreated,
        };
      },
    );

    return {
      success: true,
      liked: true,

      alreadyLiked:
        result.alreadyLiked,

      notificationCreated:
        result.notificationCreated,

      message:
        result.alreadyLiked ?
          "이미 좋아요 상태입니다." :
          "좋아요 성공",
    };
  },
);
