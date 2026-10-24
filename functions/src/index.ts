import * as admin from "firebase-admin";

if (admin.apps.length === 0) {
  admin.initializeApp();
}

export {followUser} from "./follow/followUser";
export {unfollowUser} from "./follow/unfollowUser";

export {feedLike} from "./feed/like/like";
export {feedUnlike} from "./feed/like/unlike";

export {
  onWorkoutFinishCreated,
} from "./ranking/onWorkoutFinishCreated";

export {
  deleteUserAccount,
} from "./delete/deleteAccount";

export {blockUser} from "./blockUser/blockUser";
export {unblockUser} from "./blockUser/unblockUser";

export {createReport} from "./report/createReport";

export {
  feedCommentCreate,
  feedCommentUpdate,
  feedCommentDelete,
} from "./feed/comment/comment";

export {
  sendPushOnNotificationCreated,
} from "./send_on_notification_created";
