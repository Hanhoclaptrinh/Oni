import express from "express";
import * as msgController from "../controllers/msgController.js";
import { protectedRoute } from "@bGV2aW5oaGFu/core-engine";

const router = express.Router();

router.use(protectedRoute);

router.patch("/:conversationId/seen", msgController.markMessagesAsSeenHandler);

router.get("/:conversationId", msgController.getMessagesHandler);
router.post("/:conversationId", msgController.sendMessageHandler);

router.patch("/:msgId/hide", msgController.deleteMessageForMeHandler);

export default router;
