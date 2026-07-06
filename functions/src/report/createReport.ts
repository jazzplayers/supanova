import {onCall, HttpsError} from "firebase-functions/v2/https";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

const db = getFirestore();

const dailyReportLimit = 20;
const hideThreshold = 3;

const allowedTargetTypes = [
  "workoutFinish",
  "user",
] as const;

const allowedReasons = [
  "spam",
  "harassment",
  "hate",
  "sexual",
  "violence",
  "privacy",
  "illegal",
  "other",
] as const;

type TargetType = typeof allowedTargetTypes[number];
type ReasonCode = typeof allowedReasons[number];

interface CreateReportData {
  targetType?: unknown;
  targetId?: unknown;
  reasonCode?: unknown;
  reasonText?: unknown;
}

interface TargetInfo {
  targetOwnerId: string;
  snapshot: Record<string, unknown>;
}

interface TransactionResult {
  alreadyReported: boolean;
}

/**
 * Checks whether the given value is a valid report target type.
 *
 * @param {unknown} value Value to check.
 * @return {boolean} True if the value is a valid target type.
 */
function isValidTargetType(value: unknown): value is TargetType {
  return typeof value === "string" &&
    allowedTargetTypes.includes(value as TargetType);
}

/**
 * Checks whether the given value is a valid report reason code.
 *
 * @param {unknown} value Value to check.
 * @return {boolean} True if the value is a valid reason code.
 */
function isValidReasonCode(value: unknown): value is ReasonCode {
  return typeof value === "string" &&
    allowedReasons.includes(value as ReasonCode);
}

/**
 * Converts a value to number safely.
 *
 * @param {unknown} value Value to convert.
 * @return {number} Converted number or zero.
 */
function toSafeNumber(value: unknown): number {
  if (typeof value !== "number") {
    return 0;
  }

  if (!Number.isFinite(value)) {
    return 0;
  }

  return value;
}

/**
 * Normalizes report reason text.
 *
 * @param {unknown} value Raw reason text.
 * @return {string} Trimmed reason text.
 */
function normalizeReasonText(value: unknown): string {
  if (typeof value !== "string") {
    return "";
  }

  return value.trim();
}

/**
 * Gets current date key based on Korea time.
 *
 * @return {string} Date key in YYYY-MM-DD format.
 */
function getKstDateKey(): string {
  const formatter = new Intl.DateTimeFormat("en-US", {
    timeZone: "Asia/Seoul",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  });

  const parts = formatter.formatToParts(new Date());

  const year = parts.find((part) => part.type === "year")?.value;
  const month = parts.find((part) => part.type === "month")?.value;
  const day = parts.find((part) => part.type === "day")?.value;

  if (!year || !month || !day) {
    throw new HttpsError(
      "internal",
      "날짜 정보를 생성할 수 없습니다.",
    );
  }

  return `${year}-${month}-${day}`;
}

/**
 * Gets owner id and snapshot data of the report target.
 *
 * @param {TargetType} targetType Type of the report target.
 * @param {string} targetId Id of the report target.
 * @return {Promise<TargetInfo>} Target owner id and snapshot data.
 */
async function getTargetInfo(
  targetType: TargetType,
  targetId: string,
): Promise<TargetInfo> {
  if (targetType === "workoutFinish") {
    const snap = await db
      .collection("workoutFinish")
      .doc(targetId)
      .get();

    if (!snap.exists) {
      throw new HttpsError(
        "not-found",
        "신고할 게시글을 찾을 수 없습니다.",
      );
    }

    const data = snap.data() ?? {};
    const targetOwnerId = data.userId;

    if (
      typeof targetOwnerId !== "string" ||
      targetOwnerId.length === 0
    ) {
      throw new HttpsError(
        "failed-precondition",
        "게시글 작성자 정보가 없습니다.",
      );
    }

    return {
      targetOwnerId,
      snapshot: {
        userId: data.userId ?? null,
        distanceMeters: data.distanceMeters ?? null,
        seconds: data.seconds ?? null,
        speedKmh: data.speedKmh ?? null,
        paceMinPerKm: data.paceMinPerKm ?? null,
        workoutImagesUrl: data.workoutImagesUrl ?? [],
        timestamp: data.timestamp ?? null,
        createdAt: data.createdAt ?? null,
      },
    };
  }

  if (targetType === "user") {
    const snap = await db
      .collection("users")
      .doc(targetId)
      .get();

    if (!snap.exists) {
      throw new HttpsError(
        "not-found",
        "신고할 유저를 찾을 수 없습니다.",
      );
    }

    const data = snap.data() ?? {};

    return {
      targetOwnerId: targetId,
      snapshot: {
        uid: targetId,
        displayName: data.displayName ?? null,
        displayNameKey: data.displayNameKey ?? null,
        profileImageUrl: data.profileImageUrl ?? null,
        bio: data.bio ?? null,
      },
    };
  }

  throw new HttpsError(
    "invalid-argument",
    "지원하지 않는 신고 대상입니다.",
  );
}

/**
 * Creates a report document and hides the target for the reporter.
 *
 * @return {Promise<{
 * ok: boolean,
 * hidden: boolean,
 * alreadyReported: boolean,
 * reportId: string
 * }>} Report result.
 */
export const createReport = onCall(
  {
    region: "asia-northeast3",

    // App Check 테스트가 끝난 뒤 켜면 됩니다.
    // enforceAppCheck: true,
  },
  async (request) => {
    const uid = request.auth?.uid;

    if (!uid) {
      throw new HttpsError(
        "unauthenticated",
        "로그인이 필요합니다.",
      );
    }

    const data = request.data as CreateReportData;

    if (!isValidTargetType(data.targetType)) {
      throw new HttpsError(
        "invalid-argument",
        "신고 대상이 올바르지 않습니다.",
      );
    }

    if (
      typeof data.targetId !== "string" ||
      data.targetId.trim().length === 0
    ) {
      throw new HttpsError(
        "invalid-argument",
        "신고 대상 ID가 없습니다.",
      );
    }

    if (!isValidReasonCode(data.reasonCode)) {
      throw new HttpsError(
        "invalid-argument",
        "신고 사유가 올바르지 않습니다.",
      );
    }

    const targetType = data.targetType;
    const targetId = data.targetId.trim();
    const reasonCode = data.reasonCode;
    const reasonText = normalizeReasonText(data.reasonText);

    if (reasonText.length > 300) {
      throw new HttpsError(
        "invalid-argument",
        "신고 내용은 300자 이하로 입력해주세요.",
      );
    }

    const {
      targetOwnerId,
      snapshot,
    } = await getTargetInfo(targetType, targetId);

    if (targetOwnerId === uid) {
      throw new HttpsError(
        "failed-precondition",
        "본인은 신고할 수 없습니다.",
      );
    }

    const dateKey = getKstDateKey();
    const reportId = `${uid}_${targetType}_${targetId}`;
    const targetKey = `${targetType}_${targetId}`;

    const reportRef = db
      .collection("reports")
      .doc(reportId);

    const hiddenRef = db
      .collection("users")
      .doc(uid)
      .collection("hiddenContent")
      .doc(targetKey);

    const rateLimitRef = db
      .collection("users")
      .doc(uid)
      .collection("rateLimits")
      .doc(`report_${dateKey}`);

    const targetRef = targetType === "workoutFinish" ?
      db.collection("workoutFinish").doc(targetId) :
      null;

    const transactionResult = await db.runTransaction(
      async (tx): Promise<TransactionResult> => {
        const existingReport = await tx.get(reportRef);

        if (existingReport.exists) {
          tx.set(
            hiddenRef,
            {
              targetType,
              targetId,
              targetOwnerId,
              source: "report",
              updatedAt: FieldValue.serverTimestamp(),
            },
            {merge: true},
          );

          return {
            alreadyReported: true,
          };
        }

        const rateLimitSnap = await tx.get(rateLimitRef);
        const rateLimitData = rateLimitSnap.data() ?? {};
        const currentDailyCount = toSafeNumber(rateLimitData.count);

        if (currentDailyCount >= dailyReportLimit) {
          throw new HttpsError(
            "resource-exhausted",
            "오늘 신고 가능 횟수를 초과했습니다.",
          );
        }

        let nextReportsCount = 1;

        if (targetRef !== null) {
          const targetSnap = await tx.get(targetRef);

          if (!targetSnap.exists) {
            throw new HttpsError(
              "not-found",
              "신고할 게시글을 찾을 수 없습니다.",
            );
          }

          const targetData = targetSnap.data() ?? {};
          const currentReportsCount = toSafeNumber(
            targetData.reportsCount,
          );

          nextReportsCount = currentReportsCount + 1;
        }

        tx.set(reportRef, {
          reporterId: uid,
          reporterUid: uid,
          targetType,
          targetId,
          targetKey,
          targetOwnerId,
          targetOwnerUid: targetOwnerId,
          reasonCode,
          reasonText,
          status: "open",
          snapshot,
          reviewedAt: null,
          reviewedBy: null,
          actionTaken: null,
          adminNote: "",
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        tx.set(hiddenRef, {
          targetType,
          targetId,
          targetOwnerId,
          targetOwnerUid: targetOwnerId,
          source: "report",
          createdAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        });

        if (rateLimitSnap.exists) {
          tx.update(rateLimitRef, {
            count: FieldValue.increment(1),
            updatedAt: FieldValue.serverTimestamp(),
          });
        } else {
          tx.set(rateLimitRef, {
            dateKey,
            count: 1,
            createdAt: FieldValue.serverTimestamp(),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }

        if (targetRef !== null) {
          if (nextReportsCount >= hideThreshold) {
            tx.update(targetRef, {
              reportsCount: FieldValue.increment(1),
              updatedAt: FieldValue.serverTimestamp(),
              moderationStatus: "hidden_pending_review",
            });
          } else {
            tx.update(targetRef, {
              reportsCount: FieldValue.increment(1),
              updatedAt: FieldValue.serverTimestamp(),
            });
          }
        }

        return {
          alreadyReported: false,
        };
      },
    );

    return {
      ok: true,
      hidden: true,
      alreadyReported: transactionResult.alreadyReported,
      reportId,
    };
  },
);
