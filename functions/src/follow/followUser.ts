import {onCall, HttpsError} from "firebase-functions/v2/https";
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
    const targetUid = String(data?.targetUid ?? "").trim();

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

    const myRef = db.collection("users").doc(myUid);
    const targetRef = db.collection("users").doc(targetUid);

    const followingRef = myRef
      .collection("followings")
      .doc(targetUid);

    const followerRef = targetRef
      .collection("followers")
      .doc(myUid);

    let alreadyFollowing = false;

    await db.runTransaction(async (tx) => {
      const myDoc = await tx.get(myRef);
      const targetDoc = await tx.get(targetRef);
      const followingDoc = await tx.get(followingRef);
      const followerDoc = await tx.get(followerRef);

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

      const isFollowingDocExists = followingDoc.exists;
      const isFollowerDocExists = followerDoc.exists;

      if (isFollowingDocExists && isFollowerDocExists) {
        alreadyFollowing = true;

        // 예전 문서에 필드가 부족한 경우 보정
        tx.set(
          followingRef,
          {
            uid: targetUid,
            userId: myUid,
            targetUid,
            type: "following",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        tx.set(
          followerRef,
          {
            uid: myUid,
            userId: myUid,
            targetUid,
            type: "follower",
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        return;
      }

      tx.set(
        followingRef,
        {
          // 기존 코드 호환용
          uid: targetUid,

          // 정리/조회용 명확한 필드
          userId: myUid,
          targetUid,
          type: "following",

          followedAt: isFollowingDocExists ?
            followingDoc.data()?.followedAt ??
              admin.firestore.FieldValue.serverTimestamp() :
            admin.firestore.FieldValue.serverTimestamp(),

          createdAt: isFollowingDocExists ?
            followingDoc.data()?.createdAt ??
              admin.firestore.FieldValue.serverTimestamp() :
            admin.firestore.FieldValue.serverTimestamp(),

          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
          merge: true,
        },
      );

      tx.set(
        followerRef,
        {
          // 기존 코드 호환용
          uid: myUid,

          // 정리/조회용 명확한 필드
          userId: myUid,
          targetUid,
          type: "follower",

          followedAt: isFollowerDocExists ?
            followerDoc.data()?.followedAt ??
              admin.firestore.FieldValue.serverTimestamp() :
            admin.firestore.FieldValue.serverTimestamp(),

          createdAt: isFollowerDocExists ?
            followerDoc.data()?.createdAt ??
              admin.firestore.FieldValue.serverTimestamp() :
            admin.firestore.FieldValue.serverTimestamp(),

          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {
          merge: true,
        },
      );

      if (!isFollowingDocExists) {
        tx.update(myRef, {
          followingsCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      if (!isFollowerDocExists) {
        tx.update(targetRef, {
          followersCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    return {
      success: true,
      following: true,
      alreadyFollowing,
      message: alreadyFollowing ? "이미 팔로우 중입니다." : "팔로우 성공",
    };
  },
);
