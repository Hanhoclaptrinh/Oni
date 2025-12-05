import express from "express";
import { protectedRoute } from "../middleware/authMiddleware.js";
import * as cvsController from "../controllers/cvsController.js";
const router = express.Router();

router.use(protectedRoute);

router.get("/me", cvsController.getMyConversationsHandler);

router.post("/private", cvsController.createPrivateConversationHandler);

router.post("/group", cvsController.createGroupConversationHandler);

router.delete("/:conversationId", cvsController.deleteConversationHandler);

export default router;
