import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

const MAX_BATCH_SIZE = 400;

/**
 * Deletes all files under the given Cloud Storage prefix.
 *
 * @param {string} prefix Storage folder prefix.
 * @return {Promise<void>} Resolves when deletion attempt finishes.
 */
async function deleteStoragePrefix(prefix: string): Promise<void> {
  try {
    await bucket.deleteFiles({
      prefix,
      force: true,
    });
  } catch (e) {
    logger.warn("Storage delete failed", {
      prefix,
      error: e,
    });
  }
}

/**
 * Removes follower and following relations for the deleting user.
 *
 * @param {string} uid User id to clean up.
 * @return {Promise<void>} Resolves when follow relations are cleaned.
 */
async function cleanupFollowRelations(uid: string): Promise<void> {
  const userRef = db.collection("users").doc(uid);

  const followersSnap = await userRef.collection("followers").get();
  const followingsSnap = await userRef.collection("followings").get();

  let batch = db.batch();
  let writeCount = 0;

  /**
   * Commits the current batch when it reaches the limit.
   *
   * @param {boolean} force Whether to commit remaining writes.
   * @return {Promise<void>} Resolves when commit is done if needed.
   */
  async function commitIfNeeded(force = false): Promise<void> {
    if (writeCount >= MAX_BATCH_SIZE || (force && writeCount > 0)) {
      await batch.commit();
      batch = db.batch();
      writeCount = 0;
    }
  }

  for (const doc of followersSnap.docs) {
    const followerUid = doc.id;
    const followerUserRef = db.collection("users").doc(followerUid);

    const followerUserSnap = await followerUserRef.get();

    batch.delete(
      followerUserRef.collection("followings").doc(uid),
    );
    writeCount++;

    if (followerUserSnap.exists) {
      const followerData = followerUserSnap.data();
      const rawFollowingsCount = followerData?.followingsCount;

      const currentFollowingsCount =
        typeof rawFollowingsCount === "number" ?
          rawFollowingsCount :
          0;

      batch.update(followerUserRef, {
        followingsCount: Math.max(0, currentFollowingsCount - 1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      writeCount++;
    }

    await commitIfNeeded();
  }

  for (const doc of followingsSnap.docs) {
    const targetUid = doc.id;
    const targetUserRef = db.collection("users").doc(targetUid);

    const targetUserSnap = await targetUserRef.get();

    batch.delete(
      targetUserRef.collection("followers").doc(uid),
    );
    writeCount++;

    if (targetUserSnap.exists) {
      const targetData = targetUserSnap.data();
      const rawFollowersCount = targetData?.followersCount;

      const currentFollowersCount =
        typeof rawFollowersCount === "number" ?
          rawFollowersCount :
          0;

      batch.update(targetUserRef, {
        followersCount: Math.max(0, currentFollowersCount - 1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      writeCount++;
    }

    await commitIfNeeded();
  }

  await commitIfNeeded(true);
}

/**
 * Removes likes created by the deleting user.
 *
 * @param {string} uid User id to clean up.
 * @return {Promise<void>} Resolves when likes are cleaned.
 */
async function cleanupLikesByUser(uid: string): Promise<void> {
  const likesByUserIdSnap = await db
    .collectionGroup("likes")
    .where("userId", "==", uid)
    .get();

  const likesByUidSnap = await db
    .collectionGroup("likes")
    .where("uid", "==", uid)
    .get();

  const likeDocs = [...likesByUserIdSnap.docs];
  const seenPaths = new Set<string>();

  for (const doc of likeDocs) {
    seenPaths.add(doc.ref.path);
  }

  for (const doc of likesByUidSnap.docs) {
    if (!seenPaths.has(doc.ref.path)) {
      likeDocs.push(doc);
      seenPaths.add(doc.ref.path);
    }
  }

  let batch = db.batch();
  let writeCount = 0;

  /**
   * Commits the current batch when it reaches the limit.
   *
   * @param {boolean} force Whether to commit remaining writes.
   * @return {Promise<void>} Resolves when commit is done if needed.
   */
  async function commitIfNeeded(force = false): Promise<void> {
    if (writeCount >= MAX_BATCH_SIZE || (force && writeCount > 0)) {
      await batch.commit();
      batch = db.batch();
      writeCount = 0;
    }
  }

  for (const likeDoc of likeDocs) {
    const workoutRef = likeDoc.ref.parent.parent;

    batch.delete(likeDoc.ref);
    writeCount++;

    if (workoutRef != null) {
      const workoutSnap = await workoutRef.get();

      if (workoutSnap.exists) {
        const workoutData = workoutSnap.data();
        const rawLikesCount = workoutData?.likesCount;

        const currentLikesCount =
          typeof rawLikesCount === "number" ? rawLikesCount : 0;

        batch.update(workoutRef, {
          likesCount: Math.max(0, currentLikesCount - 1),
          likedByUserIds: admin.firestore.FieldValue.arrayRemove(uid),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        writeCount++;
      }
    }

    await commitIfNeeded();
  }

  await commitIfNeeded(true);
}

/**
 * Deletes workout finish documents created by the deleting user.
 *
 * @param {string} uid User id to clean up.
 * @return {Promise<void>} Resolves when workout documents are deleted.
 */
async function cleanupWorkoutFinish(uid: string): Promise<void> {
  const workoutSnap = await db
    .collection("workoutFinish")
    .where("userId", "==", uid)
    .get();

  for (const doc of workoutSnap.docs) {
    await db.recursiveDelete(doc.ref);
  }
}

/**
 * Removes the deleting user from all ranking documents.
 *
 * @param {string} uid User id to clean up.
 * @return {Promise<void>} Resolves when rankings are cleaned.
 */
async function cleanupRankings(uid: string): Promise<void> {
  const rankingRefs = await db.collection("rankings").listDocuments();

  let batch = db.batch();
  let writeCount = 0;

  /**
   * Commits the current batch when it reaches the limit.
   *
   * @param {boolean} force Whether to commit remaining writes.
   * @return {Promise<void>} Resolves when commit is done if needed.
   */
  async function commitIfNeeded(force = false): Promise<void> {
    if (writeCount >= MAX_BATCH_SIZE || (force && writeCount > 0)) {
      await batch.commit();
      batch = db.batch();
      writeCount = 0;
    }
  }

  for (const rankingRef of rankingRefs) {
    batch.delete(rankingRef.collection("users").doc(uid));
    writeCount++;

    await commitIfNeeded();
  }

  await commitIfNeeded(true);
}

/**
 * Deletes nickname reservation documents for the deleting user.
 *
 * @param {string} displayNameKey Normalized display name key.
 * @return {Promise<void>} Resolves when nickname documents are deleted.
 */
async function cleanupDisplayNameDocs(
  displayNameKey: string,
): Promise<void> {
  if (displayNameKey === "") {
    return;
  }

  await Promise.allSettled([
    db.collection("displayNames").doc(displayNameKey).delete(),
    db.collection("usernames").doc(displayNameKey).delete(),
  ]);
}

export const deleteUserAccount = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (uid == null) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const userRef = db.collection("users").doc(uid);
    const userSnap = await userRef.get();

    let displayNameKey = "";

    if (userSnap.exists) {
      const data = userSnap.data();

      displayNameKey = String(
        data?.displayNameKey ?? "",
      ).trim().toLowerCase();
    }

    try {
      logger.info("deleteUserAccount started", {
        uid,
      });

      await cleanupFollowRelations(uid);
      await cleanupLikesByUser(uid);
      await cleanupWorkoutFinish(uid);
      await cleanupRankings(uid);
      await cleanupDisplayNameDocs(displayNameKey);

      await deleteStoragePrefix(`profiles/${uid}/`);
      await deleteStoragePrefix(`workouts/${uid}/`);
      await deleteStoragePrefix(`workoutFinish/${uid}/`);

      await db.recursiveDelete(userRef);

      await admin.auth().deleteUser(uid);

      logger.info("deleteUserAccount completed", {
        uid,
      });

      return {
        ok: true,
      };
    } catch (e) {
      logger.error("deleteUserAccount failed", {
        uid,
        error: e,
      });

      throw new HttpsError(
        "internal",
        "계정 삭제 중 오류가 발생했습니다.",
      );
    }
  },
);
