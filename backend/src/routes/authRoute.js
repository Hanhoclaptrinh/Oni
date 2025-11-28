import express from "express";
import * as authController from "../controllers/authController.js";
const router = express.Router();

router.post("/signup", authController.signUpHandler);
router.post("/signin", authController.signInHandler);
router.post("/signout", authController.signOutHandler);
router.post("/refresh", authController.refreshTokenHandler);

export default router;
