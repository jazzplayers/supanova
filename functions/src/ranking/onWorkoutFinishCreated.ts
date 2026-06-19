import * as admin from "firebase-admin";
import {onDocumentCreated} from "firebase-functions/v2/firestore";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

const MIN_RANKING_DISTANCE_METERS = 300;
const MIN_RANKING_SECONDS = 60;
const MAX_RANKING_AVERAGE_SPEED_KMH = 24;

/**
 * Converts Firestore Timestamp or Date values into a JavaScript Date.
 *
 * @param {unknown} value Firestore Timestamp, Date, or unknown value.
 * @return {Date | null} Converted Date or null.
 */
function toDateOrNull(value: unknown): Date | null {
  if (value instanceof Date) {
    return value;
  }

  if (value === null || typeof value !== "object") {
    return null;
  }

  const timestampLike = value as { toDate?: unknown };

  if (typeof timestampLike.toDate === "function") {
    return timestampLike.toDate();
  }

  return null;
}

/**
 * Resolves the workout date from workoutFinish data.
 *
 * @param {FirebaseFirestore.DocumentData} data Workout finish data.
 * @return {Date} Workout date.
 */
function getWorkoutDate(
  data: FirebaseFirestore.DocumentData,
): Date {
  return (
    toDateOrNull(data.timestamp) ??
    toDateOrNull(data.createdAt) ??
    new Date()
  );
}

/**
 * Formats a Date into yyyyMM using the Asia/Seoul timezone.
 *
 * @param {Date} date Date to format.
 * @return {string} Formatted year-month string.
 */
function getYearMonthKst(date: Date): string {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Seoul",
    year: "numeric",
    month: "2-digit",
  }).formatToParts(date);

  const year =
    parts.find((part) => part.type === "year")?.value ??
    String(date.getFullYear());

  const month =
    parts.find((part) => part.type === "month")?.value ??
    String(date.getMonth() + 1).padStart(2, "0");

  return `${year}${month}`;
}

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

    if (!Number.isFinite(distanceMeters)) {
      console.log("distanceMeters is not finite:", distanceMeters);
      return;
    }

    if (!Number.isFinite(seconds)) {
      console.log("seconds is not finite:", seconds);
      return;
    }

    const averageSpeedKmh = (distanceMeters / seconds) * 3.6;

    let rankingInvalidReason: string | null = null;

    if (distanceMeters < MIN_RANKING_DISTANCE_METERS) {
      rankingInvalidReason = "distance_too_short";
    } else if (seconds < MIN_RANKING_SECONDS) {
      rankingInvalidReason = "duration_too_short";
    } else if (averageSpeedKmh > MAX_RANKING_AVERAGE_SPEED_KMH) {
      rankingInvalidReason = "average_speed_too_fast";
    }

    if (data.isRankingEligible === false) {
      rankingInvalidReason =
        data.rankingInvalidReason ?? "client_marked_ineligible";
    }

    const workoutDate = getWorkoutDate(data);
    const yearMonth = getYearMonthKst(workoutDate);

    console.log("yearMonth:", yearMonth);

    const userRef = db.collection("users").doc(userId);

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

    const processedRef = db
      .collection("rankingProcessedWorkoutFinish")
      .doc(workoutFinishId);

    if (rankingInvalidReason !== null) {
      await db.runTransaction(async (transaction) => {
        const processedDoc = await transaction.get(processedRef);

        if (processedDoc.exists) {
          console.log("Already processed:", workoutFinishId);
          return;
        }

        transaction.set(processedRef, {
          workoutFinishId,
          userId,
          distanceMeters,
          seconds,
          averageSpeedKmh,
          yearMonth,
          isRankingEligible: false,
          rankingInvalidReason,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        transaction.set(
          snapshot.ref,
          {
            averageSpeedKmh,
            isRankingEligible: false,
            rankingInvalidReason,
            rankingApplied: false,
            rankingSkippedAt:
              admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true},
        );
      });

      console.log("Ranking skipped:", {
        workoutFinishId,
        userId,
        distanceMeters,
        seconds,
        averageSpeedKmh,
        rankingInvalidReason,
      });

      return;
    }

    await db.runTransaction(async (transaction) => {
      const processedDoc = await transaction.get(processedRef);
      const userDoc = await transaction.get(userRef);

      if (processedDoc.exists) {
        console.log("Already processed:", workoutFinishId);
        return;
      }

      const userData = userDoc.data();

      console.log("userData:", userData);

      const displayName =
        userData?.displayName ??
        userData?.nickname ??
        "Unknown";

      const profileImageUrl = userData?.profileImageUrl ?? null;

      const updateData = {
        userId,
        displayName,
        profileImageUrl,
        distanceMeters: admin.firestore.FieldValue.increment(
          distanceMeters,
        ),
        workoutCount: admin.firestore.FieldValue.increment(1),
        seconds: admin.firestore.FieldValue.increment(seconds),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      console.log("ranking updateData:", updateData);

      transaction.set(totalRef, updateData, {merge: true});
      transaction.set(monthlyRef, updateData, {merge: true});

      transaction.set(processedRef, {
        workoutFinishId,
        userId,
        distanceMeters,
        seconds,
        averageSpeedKmh,
        yearMonth,
        isRankingEligible: true,
        rankingInvalidReason: null,
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.set(
        snapshot.ref,
        {
          averageSpeedKmh,
          isRankingEligible: true,
          rankingInvalidReason: null,
          rankingApplied: true,
          rankingAppliedAt:
            admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true},
      );
    });

    console.log("Ranking updated successfully:", userId);
  },
);
