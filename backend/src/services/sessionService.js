import * as sessionRepository from "../repositories/sessionRepository.js";
import * as error from "../utils/error.js";

export const getSessionByRefreshToken = async (refreshToken) => {
  const session = await sessionRepository.findSessionByRefreshToken(
    refreshToken
  );

  if (!session)
    throw (
      new error() >
      error.UnauthorizedError("refresh token không hợp lệ hoặc đã bị thu hồi")
    );

  if (new Date(session.expiresAt).getTime() < Date.now()) {
    await sessionRepository.deleteSession(session._id);
    throw new error.UnauthorizedError("refresh token đã hết hạn");
  }

  return session;
};

export const createSession = async ({ userId, refreshToken }) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");

  const REFRESH_TOKEN_TTL = 14 * 24 * 60 * 60 * 1000; // thoi gian RT ton tai trong he thong -> het ttl -> re-login

  // thoi gian refresh token ttl die
  const expiresAt = Date.now() + REFRESH_TOKEN_TTL;

  return await sessionRepository.insertSession({
    userId,
    refreshToken,
    expiresAt,
  });
};

export const modifySession = async (sessionId, payload) => {
  const existingSession = await sessionRepository.findSessionById(sessionId);

  if (!existingSession) throw new error.NotFoundError("không tìm thấy session");

  return await sessionRepository.updateSession(sessionId, payload);
};

export const logout = async (refreshToken) => {
  const session = await sessionRepository.findSessionByRefreshToken(
    refreshToken
  );

  if (!session) throw new error.NotFoundError("không tìm thấy session");

  await sessionRepository.deleteSession(session._id);
};
