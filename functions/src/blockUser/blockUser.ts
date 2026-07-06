import * as admin from "firebase-admin";
import {
  FieldValue,
  getFirestore,
} from "firebase-admin/firestore";
import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = getFirestore();

type BlockUserRequest = {
  targetUid?: unknown;
};

/**
 * Converts an unknown value to a safe number.
 *
 * @param {unknown} value Value to convert.
 * @return {number} Safe number value.
 */
function getNumber(value: unknown): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  return 0;
}

export const blockUser = onCall(
  {
    region: "asia-northeast3",
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const data = request.data as BlockUserRequest;
    const rawTargetUid = data.targetUid;

    if (
      typeof rawTargetUid !== "string" ||
      rawTargetUid.trim().length === 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "차단할 사용자 정보가 올바르지 않습니다."
      );
    }

    const targetUid = rawTargetUid.trim();

    if (uid === targetUid) {
      throw new HttpsError(
        "invalid-argument",
        "자기 자신은 차단할 수 없습니다."
      );
    }

    const now = FieldValue.serverTimestamp();

    const myUserRef = db.collection("users").doc(uid);
    const targetUserRef = db.collection("users").doc(targetUid);

    const blockId = `${uid}_${targetUid}`;

    const blockRef = db
      .collection("blocks")
      .doc(blockId);

    const myBlockedUserRef = myUserRef
      .collection("blockedUsers")
      .doc(targetUid);

    const myFollowingTargetRef = myUserRef
      .collection("followings")
      .doc(targetUid);

    const targetFollowerMeRef = targetUserRef
      .collection("followers")
      .doc(uid);

    const targetFollowingMeRef = targetUserRef
      .collection("followings")
      .doc(uid);

    const myFollowerTargetRef = myUserRef
      .collection("followers")
      .doc(targetUid);

    await db.runTransaction(async (tx) => {
      const [
        myUserSnap,
        targetUserSnap,
        blockSnap,
        myBlockedUserSnap,
        myFollowingTargetSnap,
        targetFollowerMeSnap,
        targetFollowingMeSnap,
        myFollowerTargetSnap,
      ] = await Promise.all([
        tx.get(myUserRef),
        tx.get(targetUserRef),
        tx.get(blockRef),
        tx.get(myBlockedUserRef),
        tx.get(myFollowingTargetRef),
        tx.get(targetFollowerMeRef),
        tx.get(targetFollowingMeRef),
        tx.get(myFollowerTargetRef),
      ]);

      if (!myUserSnap.exists) {
        throw new HttpsError(
          "not-found",
          "내 사용자 정보를 찾을 수 없습니다."
        );
      }

      if (!targetUserSnap.exists) {
        throw new HttpsError(
          "not-found",
          "차단할 사용자를 찾을 수 없습니다."
        );
      }

      const myData = myUserSnap.data() ?? {};
      const targetData = targetUserSnap.data() ?? {};

      const myFollowersCount = getNumber(myData.followersCount);
      const myFollowingsCount = getNumber(myData.followingsCount);

      const targetFollowersCount = getNumber(
        targetData.followersCount
      );

      const targetFollowingsCount = getNumber(
        targetData.followingsCount
      );

      let myFollowersDecrease = 0;
      let myFollowingsDecrease = 0;
      let targetFollowersDecrease = 0;
      let targetFollowingsDecrease = 0;

      if (!blockSnap.exists) {
        tx.set(blockRef, {
          blockerId: uid,
          blockedId: targetUid,
          createdAt: now,
          updatedAt: now,
        });
      } else {
        tx.update(blockRef, {
          updatedAt: now,
        });
      }

      if (!myBlockedUserSnap.exists) {
        tx.set(myBlockedUserRef, {
          blockedUserId: targetUid,
          createdAt: now,
          updatedAt: now,
        });
      } else {
        tx.update(myBlockedUserRef, {
          updatedAt: now,
        });
      }

      if (myFollowingTargetSnap.exists) {
        tx.delete(myFollowingTargetRef);
        myFollowingsDecrease += 1;
      }

      if (targetFollowerMeSnap.exists) {
        tx.delete(targetFollowerMeRef);
        targetFollowersDecrease += 1;
      }

      if (targetFollowingMeSnap.exists) {
        tx.delete(targetFollowingMeRef);
        targetFollowingsDecrease += 1;
      }

      if (myFollowerTargetSnap.exists) {
        tx.delete(myFollowerTargetRef);
        myFollowersDecrease += 1;
      }

      tx.update(myUserRef, {
        followersCount: Math.max(
          0,
          myFollowersCount - myFollowersDecrease
        ),
        followingsCount: Math.max(
          0,
          myFollowingsCount - myFollowingsDecrease
        ),
        updatedAt: now,
      });

      tx.update(targetUserRef, {
        followersCount: Math.max(
          0,
          targetFollowersCount - targetFollowersDecrease
        ),
        followingsCount: Math.max(
          0,
          targetFollowingsCount - targetFollowingsDecrease
        ),
        updatedAt: now,
      });
    });

    return {
      ok: true,
      blockedUserId: targetUid,
    };
  }
);
