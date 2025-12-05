import express from "express";
import * as msgController from "../controllers/msgController.js";
import { protectedRoute } from "../middleware/authMiddleware.js";
const router = express.Router();

router.use(protectedRoute);

router.get("/:conversationId", msgController.getMessagesHandler);

router.post("/:conversationId", msgController.sendMessageHandler);

router.patch("/seen/:conversationId", msgController.markMessagesAsSeenHandler);

router.delete("/:msgId", msgController.deleteMessageHandler);

export default router;
