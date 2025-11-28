import * as userRepository from "../repositories/userRepository.js";
import * as error from "../utils/error.js";
import * as sessionService from "./sessionService.js";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import crypto from "crypto";

// tao access token voi jwt
const ACCESS_TOKEN_TTL = "10m"; // thoi gian AT song trong mot phien dang nhap -> duoc cap tu dong sau moi ttl die

export const signUp = async (payload) => {
  const { username, email, password, firstName, lastName } = payload;

  if (!username || !email || !password || !firstName || !lastName)
    throw new error.BadRequestError("vui lòng điền đủ thông tin");

  const usernameDup = await userRepository.findUserByUsername(username);
  const emailDup = await userRepository.findUserByEmail(email);

  if (usernameDup || emailDup)
    throw new error.BadRequestError("user đã tồn tại");

  const hashedPassword = await bcrypt.hash(password, 12);
  const displayName = `${firstName} ${lastName}`.trim();

  const newUser = await userRepository.insertUser({
    username,
    email,
    hashedPassword,
    displayName,
  });

  const accessToken = jwt.sign(
    {
      userId: newUser._id,
      role: newUser.role,
    },
    process.env.PRIVATE_ACCESS_TOKEN,
    { expiresIn: ACCESS_TOKEN_TTL }
  );

  const refreshToken = crypto.randomBytes(64).toString("hex");

  await sessionService.createSession({
    userId: newUser._id,
    refreshToken,
  });

  return { user: newUser, accessToken, refreshToken };
};

export const signIn = async (payload) => {
  const { email, password } = payload;

  if (!email || !password)
    throw new error.BadRequestError("vui lòng điền đầy đủ thông tin");

  const existingUser = await userRepository.findUserByEmailForLogin(email);

  if (!existingUser) throw new error.NotFoundError("không tìm thấy user này");

  const correctPassword = await bcrypt.compare(
    password,
    existingUser.hashedPassword
  );

  if (!correctPassword)
    throw new error.BadRequestError("email hoặc password không đúng");

  const accessToken = jwt.sign(
    {
      userId: existingUser._id,
      role: existingUser.role,
    },
    process.env.PRIVATE_ACCESS_TOKEN,
    { expiresIn: ACCESS_TOKEN_TTL }
  );

  const refreshToken = crypto.randomBytes(64).toString("hex");

  // luu refresh token
  await sessionService.createSession({
    userId: existingUser._id,
    refreshToken,
  });

  return { user: existingUser, accessToken, refreshToken };
};

export const signOut = async (payload) => {
  const { refreshToken } = payload;

  if (!refreshToken) throw new error.BadRequestError("thiếu refresh token");

  await sessionService.logout(refreshToken);

  return true;
};

export const refresh = async (payload) => {
  const { refreshToken } = payload;

  if (!refreshToken) throw new error.BadRequestError("thiếu refresh token");

  const existingSession = await sessionService.getSessionByRefreshToken(
    refreshToken
  );

  if (!existingSession)
    throw new error.UnauthorizedError("refresh token không hợp lệ");

  const existingUser = await userRepository.findUserById(
    existingSession.userId
  );

  if (!existingUser) throw new error.NotFoundError("không tìm thấy user");

  // server cấp một cặp AT-RT mới
  const newAccessToken = jwt.sign(
    {
      userId: existingUser._id,
      role: existingUser.role,
    },
    process.env.PRIVATE_ACCESS_TOKEN,
    { expiresIn: ACCESS_TOKEN_TTL }
  );

  const newRefreshToken = crypto.randomBytes(64).toString("hex");

  // rotation token
  const REFRESH_TOKEN_TTL = 14 * 24 * 60 * 60 * 1000;
  const newExpiresAt = Date.now() + REFRESH_TOKEN_TTL;

  await sessionService.modifySession(existingSession._id, {
    refreshToken: newRefreshToken,
    expiresAt: newExpiresAt,
  });

  return { newAccessToken, newRefreshToken };
};
