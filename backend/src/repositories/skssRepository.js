import mongoose from "mongoose";
import SocketSession from "../models/socketsession.js";

export const insertSocketSession = (userId, socketId) =>
  SocketSession.create({
    userId,
    socketId,
    isOnline: true,
    lastActive: new Date(),
  });

export const deleteSocketSession = (socketId) =>
  SocketSession.findOneAndDelete({ socketId });

export const updateStatusSocket = (socketId) =>
  SocketSession.findOneAndUpdate(
    { socketId },
    { isOnline: false, lastActive: new Date() },
    { new: true }
  );

export const findSocketSessionByUserId = (userId) =>
  SocketSession.find({ userId, isOnline: true });

export const findOnlineUsers = () =>
  SocketSession.distinct("userId", { isOnline: true });

export const deleteAllSessionsOfUser = (userId) =>
  SocketSession.deleteMany({ userId });

export const updateLastActive = (socketId) =>
  SocketSession.findOneAndUpdate(
    { socketId },
    { lastActive: new Date() },
    { new: true }
  );

export const findOnlineUsersByIds = (userIds) => {
  // Convert string userIds to ObjectIds for MongoDB query
  const objectIds = userIds.map((id) => {
    if (typeof id === "string") {
      return new mongoose.Types.ObjectId(id);
    }
    return id;
  });

  return SocketSession.distinct("userId", {
    userId: { $in: objectIds },
    isOnline: true,
  });
};
