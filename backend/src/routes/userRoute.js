import express from "express";
import * as userController from "../controllers/userController.js";
import { protectedRoute } from "../middleware/authMiddleware.js";
import { checkRole } from "../middleware/roleMiddleware.js";
const router = express.Router();

router.get("/search", protectedRoute, userController.searchUserHandler);

router.get("/me", protectedRoute, userController.getMeHandler);

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
