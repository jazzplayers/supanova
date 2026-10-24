import {onDocumentCreated} from
  "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

const db = admin.firestore();

export const sendPushOnNotificationCreated =
  onDocumentCreated(
    {
      document:
        "users/{uid}/notifications/{notificationId}",
      region: "us-central1",
    },
    async (event) => {
      const notificationDoc = event.data;

      if (!notificationDoc) {
        console.log("알림 문서 데이터가 없습니다.");
        return;
      }

      const recipientUid = String(
        event.params.uid ?? "",
      ).trim();

      const notificationId = String(
        event.params.notificationId ?? "",
      ).trim();

      if (recipientUid === "") {
        console.log("알림 수신자 UID가 없습니다.");
        return;
      }

      const notificationData =
        notificationDoc.data();

      const title = String(
        notificationData.title ??
        "SUPANOVA",
      ).trim();

      const body = String(
        notificationData.body ?? "",
      ).trim();

      const type = String(
        notificationData.type ?? "",
      ).trim();

      const actorUid = String(
        notificationData.actorUid ?? "",
      ).trim();

      const route = String(
        notificationData.route ?? "",
      ).trim();

      /*
       * 알림을 받는 사용자의 등록된 기기 조회
       */
      const deviceSnapshot = await db
        .collection("users")
        .doc(recipientUid)
        .collection("fcmDevices")
        .limit(20)
        .get();

      const devices = deviceSnapshot.docs
        .map((doc) => {
          const token = String(
            doc.data().token ?? "",
          ).trim();

          return {
            ref: doc.ref,
            token,
          };
        })
        .filter((device) => {
          return device.token !== "";
        });

      /*
       * 등록된 기기가 없는 경우
       */
      if (devices.length === 0) {
        await notificationDoc.ref.set(
          {
            pushStatus: "no-device",
            pushSuccessCount: 0,
            pushFailureCount: 0,
            pushUpdatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        console.log(
          `등록된 FCM 기기 없음: ${recipientUid}`,
        );

        return;
      }

      const tokens = devices.map(
        (device) => device.token,
      );

      try {
        const response = await admin
          .messaging()
          .sendEachForMulticast({
            tokens,

            /*
             * 잠금 화면과 알림 센터에 표시될 내용
             */
            notification: {
              title,
              body,
            },

            /*
             * Flutter에서 알림 클릭 시 사용할 데이터
             *
             * FCM data 값은 모두 문자열이어야 함
             */
            data: {
              type,
              actorUid,
              recipientUid,
              notificationId,
              route,
            },

            android: {
              priority: "high",
              notification: {
                sound: "default",
              },
            },

            apns: {
              headers: {
                "apns-priority": "10",
              },
              payload: {
                aps: {
                  sound: "default",
                },
              },
            },
          });

        /*
         * 더 이상 유효하지 않은 FCM 토큰 삭제
         */
        const invalidTokenCodes = new Set([
          "messaging/invalid-registration-token",
          "messaging/registration-token-not-registered",
        ]);

        const cleanupBatch = db.batch();
        let cleanupCount = 0;

        response.responses.forEach(
          (sendResult, index) => {
            if (sendResult.success) {
              return;
            }

            const errorCode =
              sendResult.error?.code ?? "";

            console.error(
              "FCM 개별 전송 실패",
              {
                recipientUid,
                notificationId,
                errorCode,
                errorMessage:
                  sendResult.error?.message,
              },
            );

            if (
              invalidTokenCodes.has(errorCode)
            ) {
              cleanupBatch.delete(
                devices[index].ref,
              );

              cleanupCount += 1;
            }
          },
        );

        if (cleanupCount > 0) {
          await cleanupBatch.commit();
        }

        await notificationDoc.ref.set(
          {
            pushStatus:
              response.successCount > 0 ?
                "sent" :
                "failed",

            pushSuccessCount:
              response.successCount,

            pushFailureCount:
              response.failureCount,

            pushUpdatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        console.log(
          "FCM 전송 완료",
          {
            recipientUid,
            notificationId,
            successCount:
              response.successCount,
            failureCount:
              response.failureCount,
          },
        );
      } catch (error) {
        console.error(
          "FCM 전송 중 오류 발생",
          {
            recipientUid,
            notificationId,
            error,
          },
        );

        await notificationDoc.ref.set(
          {
            pushStatus: "failed",
            pushSuccessCount: 0,
            pushError: String(error),
            pushUpdatedAt:
              admin.firestore.FieldValue
                .serverTimestamp(),
          },
          {
            merge: true,
          },
        );
      }
    },
  );
