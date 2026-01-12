import express from "express";
import * as userController from "../controllers/userController.js";
import { protectedRoute, checkRole } from "@bGV2aW5oaGFu/core-engine";
const router = express.Router();

router.get("/search", protectedRoute, userController.searchUserHandler);

router.get("/me", protectedRoute, userController.getMeHandler);
router.put("/me", protectedRoute, userController.updateMeHandler);

router.get("/", protectedRoute, checkRole, userController.getAllUsersHandler);
router.post("/", protectedRoute, checkRole, userController.createUserHandler);

router.get(
  "/:userId",
  protectedRoute,
  checkRole,
  userController.getUserByIdHandler
);
router.put(
  "/:userId",
  protectedRoute,
  checkRole,
  userController.updateUserHandler
);
router.delete(
  "/:userId",
  protectedRoute,
  checkRole,
  userController.deleteUserHandler
);

export default router;
