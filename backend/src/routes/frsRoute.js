import express from "express";
import * as frsController from "../controllers/frsController.js";
import { protectedRoute } from "../middleware/authMiddleware.js";
const router = express.Router();

router.use(protectedRoute);

router.get("/", frsController.getAllFriendsHandler);

router.get("/requests/received", frsController.getReceivedRequestsHandler);

router.get("/requests/sent", frsController.getSentRequestsHandler);

router.post("/requests", frsController.createFriendRequestHandler);

router.patch("/requests/:id/accept", frsController.acceptFriendRequestHandler);

router.patch(
  "/requests/:id/decline",
  frsController.declineFriendRequestHandler
);

router.delete("/requests/:id", frsController.cancelFriendRequestHandler);

router.delete("/:id", frsController.removeFriendHandler);

export default router;
