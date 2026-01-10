import express from "express";
import { protectedRoute } from "../middleware/authMiddleware.js";
import { checkRole } from "../middleware/roleMiddleware.js";
import * as postController from "../controllers/postController.js";

const router = express.Router();

router.use(protectedRoute);

router.post("/", postController.createPostHandler);

// router.get("/", postController.getFeedHandler);

// router.get("/:postId", postController.getPostDetailHandler);

router.patch("/:postId", postController.updatePostHandler);

router.patch("/:postId", postController.softDeletePostHandler);

router.delete("/:postId/hard", checkRole, postController.hardDeletePostHandler);

export default router;
