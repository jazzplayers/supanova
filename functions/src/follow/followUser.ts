import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const followUser = onCall(
  {
    region: "us-central1",
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
    const targetUid = String(
      data?.targetUid ?? "",
    ).trim();

    if (targetUid === "") {
      throw new HttpsError(
        "invalid-argument",
        "유효한 targetUid가 필요합니다.",
      );
    }

    if (myUid === targetUid) {
      throw new HttpsError(
        "invalid-argument",
        "자신을 팔로우할 수 없습니다.",
      );
    }

    const myRef = db
      .collection("users")
      .doc(myUid);

    const targetRef = db
      .collection("users")
      .doc(targetUid);

    const followingRef = myRef
      .collection("followings")
      .doc(targetUid);

    const followerRef = targetRef
      .collection("followers")
      .doc(myUid);

    /*
     * 새로운 팔로우 알림 문서
     *
     * 자동 ID를 사용하므로:
     * 팔로우 → 언팔로우 → 다시 팔로우 시
     * 새로운 알림을 다시 생성할 수 있음
     */
    const notificationRef = targetRef
      .collection("notifications")
      .doc();

    const result = await db.runTransaction(
      async (tx) => {
        /*
         * 트랜잭션에서는 모든 읽기를 먼저 수행
         */
        const myDoc = await tx.get(myRef);
        const targetDoc = await tx.get(targetRef);
        const followingDoc = await tx.get(
          followingRef,
        );
        const followerDoc = await tx.get(
          followerRef,
        );

        if (!myDoc.exists) {
          throw new HttpsError(
            "not-found",
            "내 사용자 정보를 찾을 수 없습니다.",
          );
        }

        if (!targetDoc.exists) {
          throw new HttpsError(
            "not-found",
            "상대 사용자를 찾을 수 없습니다.",
          );
        }

        const isFollowingDocExists =
          followingDoc.exists;

        const isFollowerDocExists =
          followerDoc.exists;

        /*
         * 둘 중 하나라도 존재하면
         * 이미 팔로우 관계가 있었던 것으로 처리
         */
        const alreadyFollowing =
          isFollowingDocExists ||
          isFollowerDocExists;

        /*
         * 양쪽 문서가 모두 없을 때만
         * 완전히 새로운 팔로우
         */
        const isNewFollow =
          !isFollowingDocExists &&
          !isFollowerDocExists;

        const followingData =
          followingDoc.data();

        const followerData =
          followerDoc.data();

        /*
         * 내 followings 문서 생성 또는 보정
         */
        tx.set(
          followingRef,
          {
            // 기존 코드 호환용
            uid: targetUid,

            // 관계 정보
            userId: myUid,
            targetUid,
            type: "following",

            followedAt:
              followingData?.followedAt ??
              admin.firestore.FieldValue
                .serverTimestamp(),

            createdAt:
              followingData?.createdAt ??
              admin.firestore.FieldValue
                .serverTimestamp(),

            updatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        /*
         * 상대방 followers 문서 생성 또는 보정
         */
        tx.set(
          followerRef,
          {
            // 기존 코드 호환용
            uid: myUid,

            // 관계 정보
            userId: myUid,
            targetUid,
            type: "follower",

            followedAt:
              followerData?.followedAt ??
              admin.firestore.FieldValue
                .serverTimestamp(),

            createdAt:
              followerData?.createdAt ??
              admin.firestore.FieldValue
                .serverTimestamp(),

            updatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        /*
         * 내 followings 문서가 실제로 없었던 경우에만
         * followingsCount 증가
         */
        if (!isFollowingDocExists) {
          tx.update(
            myRef,
            {
              followingsCount:
                admin.firestore.FieldValue
                  .increment(1),

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
          );
        }

        /*
         * 상대방 followers 문서가 실제로 없었던 경우에만
         * followersCount 증가
         */
        if (!isFollowerDocExists) {
          tx.update(
            targetRef,
            {
              followersCount:
                admin.firestore.FieldValue
                  .increment(1),

              updatedAt:
                admin.firestore.FieldValue
                  .serverTimestamp(),
            },
          );
        }

        /*
         * 양쪽 팔로우 문서가 모두 없었던
         * 완전히 새로운 팔로우일 때만 알림 생성
         */
        if (isNewFollow) {
          const myData = myDoc.data();

          const rawDisplayName = String(
            myData?.displayName ?? "",
          ).trim();

          const displayName =
            rawDisplayName === "" ?
              "새로운 사용자" :
              rawDisplayName;

          const actorProfileImageUrl = String(
            myData?.profileImageUrl ?? "",
          ).trim();

          tx.set(
            notificationRef,
            {
              /*
               * 알림 종류
               */
              type: "follow",

              /*
               * 알림을 발생시킨 사용자
               */
              actorUid: myUid,
              actorDisplayName: displayName,
              actorProfileImageUrl,

              /*
               * 알림을 받는 사용자
               */
              recipientUid: targetUid,

              /*
               * 표시할 제목과 내용
               */
              title: "새로운 팔로워",

              body:
                `${displayName}님이 ` +
                "회원님을 팔로우했습니다.",

              /*
               * 알림 클릭 시 이동할 사용자 프로필
               */
              route: `/user/${myUid}`,

              /*
               * 읽음 여부
               */
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
        }

        return {
          alreadyFollowing,
          notificationCreated: isNewFollow,
        };
      },
    );

    return {
      success: true,
      following: true,
      alreadyFollowing:
        result.alreadyFollowing,
      notificationCreated:
        result.notificationCreated,

      message:
        result.alreadyFollowing ?
          "이미 팔로우 중입니다." :
          "팔로우 성공",
    };
  },
);
