import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const feedUnlike = onCall(
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
    const workoutFinishId = String(
      data?.workoutFinishId ?? "",
    ).trim();

    if (workoutFinishId === "") {
      throw new HttpsError(
        "invalid-argument",
        "유효한 workoutFinishId가 필요합니다.",
      );
    }

    const workoutFinishRef = db
      .collection("workoutFinish")
      .doc(workoutFinishId);

    const likeRef = workoutFinishRef
      .collection("likes")
      .doc(myUid);

    let alreadyUnliked = false;

    await db.runTransaction(async (tx) => {
      const workoutFinishDoc = await tx.get(workoutFinishRef);

      if (!workoutFinishDoc.exists) {
        throw new HttpsError(
          "not-found",
          "운동 기록을 찾을 수 없습니다.",
        );
      }

      const likeDoc = await tx.get(likeRef);

      if (!likeDoc.exists) {
        alreadyUnliked = true;

        // 혹시 likedByUserIds 배열에만 남아 있는 경우 정리
        tx.update(workoutFinishRef, {
          likedByUserIds: admin.firestore.FieldValue.arrayRemove(myUid),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return;
      }

      const workoutData = workoutFinishDoc.data();
      const rawLikesCount = workoutData?.likesCount;

      const currentLikesCount =
        typeof rawLikesCount === "number" ? rawLikesCount : 0;

      tx.delete(likeRef);

      tx.update(workoutFinishRef, {
        likesCount: Math.max(0, currentLikesCount - 1),
        likedByUserIds: admin.firestore.FieldValue.arrayRemove(myUid),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return {
      success: true,
      liked: false,
      alreadyUnliked,
      message: alreadyUnliked ?
        "이미 좋아요가 취소된 상태입니다." :
        "좋아요 취소 성공",
    };
  },
);
