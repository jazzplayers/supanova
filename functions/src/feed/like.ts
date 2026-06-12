import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();

export const feedLike = onCall(async (request) => {
  const auth = request.auth;
  const data = request.data;

  if (!auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const myUid = auth.uid;
  const workoutFinishId = data.workoutFinishId;

  if (!workoutFinishId || typeof workoutFinishId !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "유효한 workoutFinishId가 필요합니다."
    );
  }

  const workoutFinishRef = db.collection("workoutFinish").doc(workoutFinishId);
  const likeRef = workoutFinishRef.collection("likes").doc(myUid);

  let alreadyLiked = false;

  await db.runTransaction(async (tx) => {
    const workoutFinishDoc = await tx.get(workoutFinishRef);
    const likeDoc = await tx.get(likeRef);

    if (!workoutFinishDoc.exists) {
      throw new HttpsError("not-found", "운동 기록을 찾을 수 없습니다.");
    }

    if (likeDoc.exists) {
      alreadyLiked = true;
      return;
    }

    tx.set(likeRef, {uid: myUid,
      likedAt: admin.firestore.FieldValue.serverTimestamp()});
    tx.update(workoutFinishRef, {
      likesCount: admin.firestore.FieldValue.increment(1),
      likedByUserIds: admin.firestore.FieldValue.arrayUnion(myUid),
    });
  });

  return {
    success: true,
    liked: true,
    alreadyLiked,
    message: alreadyLiked ? "이미 좋아요 상태입니다." : "좋아요 성공",
  };
});
