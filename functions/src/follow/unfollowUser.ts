import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const unfollowUser = onCall(
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
        "자기 자신을 언팔로우할 수 없습니다.",
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

    let alreadyUnfollowed = false;
    let fixedBrokenRelation = false;

    await db.runTransaction(async (tx) => {
      const myDoc = await tx.get(myRef);
      const targetDoc = await tx.get(targetRef);
      const followingDoc = await tx.get(followingRef);
      const followerDoc = await tx.get(followerRef);

      const followingExists = followingDoc.exists;
      const followerExists = followerDoc.exists;

      if (!followingExists && !followerExists) {
        alreadyUnfollowed = true;
        return;
      }

      if (followingExists !== followerExists) {
        fixedBrokenRelation = true;
      }

      if (followingExists) {
        tx.delete(followingRef);
      }

      if (followerExists) {
        tx.delete(followerRef);
      }

      if (followingExists && myDoc.exists) {
        const myData = myDoc.data();
        const rawFollowingsCount = myData?.followingsCount;

        const currentFollowingsCount =
          typeof rawFollowingsCount === "number" ?
            rawFollowingsCount :
            0;

        tx.update(myRef, {
          followingsCount: Math.max(0, currentFollowingsCount - 1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      if (followerExists && targetDoc.exists) {
        const targetData = targetDoc.data();
        const rawFollowersCount = targetData?.followersCount;

        const currentFollowersCount =
          typeof rawFollowersCount === "number" ?
            rawFollowersCount :
            0;

        tx.update(targetRef, {
          followersCount: Math.max(0, currentFollowersCount - 1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    });

    return {
      success: true,
      following: false,
      alreadyUnfollowed,
      fixedBrokenRelation,
      message: alreadyUnfollowed ?
        "이미 팔로우가 취소된 상태입니다." :
        "언팔로우 성공",
    };
  },
);
