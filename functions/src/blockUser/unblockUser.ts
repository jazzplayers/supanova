import * as admin from "firebase-admin";
import {getFirestore} from "firebase-admin/firestore";
import {HttpsError, onCall} from "firebase-functions/v2/https";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = getFirestore();

type UnblockUserRequest = {
  targetUid?: unknown;
};

export const unblockUser = onCall(
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

    const data = request.data as UnblockUserRequest;
    const rawTargetUid = data.targetUid;

    if (
      typeof rawTargetUid !== "string" ||
      rawTargetUid.trim().length === 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "차단 해제할 사용자 정보가 올바르지 않습니다."
      );
    }

    const targetUid = rawTargetUid.trim();

    if (uid === targetUid) {
      throw new HttpsError(
        "invalid-argument",
        "자기 자신은 차단 해제할 수 없습니다."
      );
    }

    const blockId = `${uid}_${targetUid}`;

    const fixedBlockRef = db
      .collection("blocks")
      .doc(blockId);

    const myBlockedUserRef = db
      .collection("users")
      .doc(uid)
      .collection("blockedUsers")
      .doc(targetUid);

    const oldBlockSnapshot = await db
      .collection("blocks")
      .where("blockerUid", "==", uid)
      .where("blockedUid", "==", targetUid)
      .get();

    const batch = db.batch();

    batch.delete(fixedBlockRef);
    batch.delete(myBlockedUserRef);

    oldBlockSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();

    return {
      ok: true,
      unblockedUserId: targetUid,
      deletedBlockCount: oldBlockSnapshot.size,
      deletedFixedBlockId: blockId,
    };
  }
);
