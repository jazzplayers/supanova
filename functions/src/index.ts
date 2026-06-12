import * as admin from "firebase-admin";

admin.initializeApp();

export {followUser} from "./follow/followUser";

export {unfollowUser} from "./follow/unfollowUser";

export {feedLike} from "./feed/like";

export {feedUnlike} from "./feed/unlike";

export {onWorkoutFinishCreated} from "./ranking/onWorkoutFinishCreated";
