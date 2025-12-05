import * as skssRepository from "../repositories/skssRepository.js";
import * as error from "../utils/error.js";

export const createSocketSessionService = async (userId, socketId) => {
  if (!userId) throw new error.BadRequestError("thiếu userid");

  // xóa session cũ theo socketId (tránh ghost session)
  await skssRepository.deleteSocketSession(socketId);

  // tạo session mới
  const session = await skssRepository.insertSocketSession(userId, socketId);

  return session;
};

export const setOfflineSessionService = async (socketId) => {
  if (!socketId) throw new error.BadRequestError("thiếu socketid");

  const session = await skssRepository.updateStatusSocket(socketId);

  return session;
};

export const getUserSessionsService = async (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userid");

  return skssRepository.findSocketSessionByUserId(userId);
};

export const deleteAllSessionsOfUserService = async (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userid");

  return skssRepository.deleteAllSessionsOfUser(userId);
};

export const updateLastActiveService = async (socketId) => {
  if (!socketId) throw new error.BadRequestError("thiếu socketid");

  return skssRepository.updateLastActive(socketId);
};

export const findOnlineUsersService = async () => {
  return skssRepository.findOnlineUsers();
};
