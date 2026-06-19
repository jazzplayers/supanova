import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const feedLike = onCall(
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

    let alreadyLiked = false;

    await db.runTransaction(async (tx) => {
      const workoutFinishDoc = await tx.get(workoutFinishRef);

      if (!workoutFinishDoc.exists) {
        throw new HttpsError(
          "not-found",
          "운동 기록을 찾을 수 없습니다.",
        );
      }

      const likeDoc = await tx.get(likeRef);

      if (likeDoc.exists) {
        alreadyLiked = true;

        // 예전에 uid만 저장된 좋아요 문서를 탈퇴 정리 가능하게 보정
        tx.set(
          likeRef,
          {
            uid: myUid,
            userId: myUid,
            workoutId: workoutFinishId,
            workoutFinishId,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        tx.update(workoutFinishRef, {
          likedByUserIds: admin.firestore.FieldValue.arrayUnion(myUid),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return;
      }

      tx.set(likeRef, {
        // 기존 코드 호환용
        uid: myUid,

        // 탈퇴 정리용 핵심 필드
        userId: myUid,
        workoutId: workoutFinishId,
        workoutFinishId,

        likedAt: admin.firestore.FieldValue.serverTimestamp(),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      tx.update(workoutFinishRef, {
        likesCount: admin.firestore.FieldValue.increment(1),
        likedByUserIds: admin.firestore.FieldValue.arrayUnion(myUid),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return {
      success: true,
      liked: true,
      alreadyLiked,
      message: alreadyLiked ?
        "이미 좋아요 상태입니다." :
        "좋아요 성공",
    };
  },
);
