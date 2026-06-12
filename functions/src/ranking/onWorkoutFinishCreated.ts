import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

const db = admin.firestore();

export const onWorkoutFinishCreated = onDocumentCreated(
  "workoutFinish/{workoutFinishId}",
  async (event) => {
    console.log("onWorkoutFinishCreated triggered");

    const snapshot = event.data;

    if (!snapshot) {
      console.log("No snapshot");
      return;
    }

    const data = snapshot.data();
    const workoutFinishId = event.params.workoutFinishId;

    console.log("workoutFinishId:", workoutFinishId);
    console.log("workoutFinish data:", data);

    const userId = data.userId;
    const distanceMeters = data.distanceMeters;
    const seconds = data.seconds;

    if (!userId || typeof userId !== "string") {
      console.log("Invalid userId:", userId);
      return;
    }

    if (typeof distanceMeters !== "number" || distanceMeters <= 0) {
      console.log("Invalid distanceMeters:", distanceMeters);
      return;
    }

    if (typeof seconds !== "number" || seconds <= 0) {
      console.log("Invalid seconds:", seconds);
      return;
    }

    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    console.log("userData:", userData);

    const displayName =
      userData?.displayName ??
      userData?.nickname ??
      "Unknown";

    const profileImageUrl = userData?.profileImageUrl ?? null;

    const now = new Date();
    const yearMonth =
      `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, "0")}`;

    console.log("yearMonth:", yearMonth);

    const totalRef = db
      .collection("rankings")
      .doc("total_running")
      .collection("users")
      .doc(userId);

    const monthlyRef = db
      .collection("rankings")
      .doc(`monthly_${yearMonth}_running`)
      .collection("users")
      .doc(userId);

    const updateData = {
      userId,
      displayName,
      profileImageUrl,
      distanceMeters: admin.firestore.FieldValue.increment(distanceMeters),
      workoutCount: admin.firestore.FieldValue.increment(1),
      seconds: admin.firestore.FieldValue.increment(seconds),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    console.log("ranking updateData:", updateData);

    const batch = db.batch();

    batch.set(totalRef, updateData, {merge: true});
    batch.set(monthlyRef, updateData, {merge: true});

    await batch.commit();

    console.log("Ranking updated successfully:", userId);
  }
);
