import {onCall, HttpsError} from "firebase-functions/v2/https";

import * as admin from "firebase-admin";

const db = admin.firestore();

export const unfollowUser = onCall(async (request) => {
  const auth = request.auth;
  const data = request.data;

  if (!auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const myUid = auth.uid;
  const targetUid = data.targetUid;

  if (!targetUid || typeof targetUid !== "string") {
    throw new HttpsError("invalid-argument", "유효한 targetUid가 필요합니다.");
  }

  const myRef = db.collection("users").doc(myUid);
  const targetRef = db.collection("users").doc(targetUid);

  const followingRef = myRef.collection("followings").doc(targetUid);
  const followerRef = targetRef.collection("followers").doc(myUid);

  await db.runTransaction(async (tx) => {
    const followingDoc = await tx.get(followingRef);

    if (!followingDoc.exists) {
      throw new HttpsError("not-found", "팔로우 중이 아닙니다.");
    }

    tx.delete(followingRef);
    tx.delete(followerRef);
    tx.update(myRef,
      {followingsCount: admin.firestore.FieldValue.increment(-1)});
    tx.update(targetRef,
      {followersCount: admin.firestore.FieldValue.increment(-1)});
  });

  return {success: true, message: "언팔로우 성공"};
});
