import {
  createSocketSessionService,
  setOfflineSessionService,
} from "../../services/skssService.js";

import { getFriendIdsOfUser } from "../../services/frsService.js";

import Conversation from "../../models/conversation.js";

export default function registerPresenceHandler(io, socket) {
  console.log("presence handler loaded for", socket.id);

  const userId = socket.userId;

  // online
  (async () => {
    try {
      // join vào room cá nhân - nhắn riêng (room == userid)
      socket.join(userId);

      // Lưu session
      await createSocketSessionService(userId, socket.id);

      // khi đã là bạn
      const friendIds = await getFriendIdsOfUser(userId);

      // khi không là bạn - cho phép người lạ nhắn tin nhau
      const convos = await Conversation.find({ members: userId })
        .select("members")
        .lean();

      const participants = convos
        .flatMap((c) =>
          c.members.filter((m) => m.toString() !== userId.toString())
        )
        .map((id) => id.toString());

      const notifyIds = [...new Set([...friendIds, ...participants])];

      if (notifyIds.length > 0) {
        console.log("notifyIds:", notifyIds);
        console.log("EMIT user_online to:", notifyIds);

        io.to(notifyIds).emit("user_online", userId);
      }

      console.log(`User ${userId} online via socket ${socket.id}`);
    } catch (err) {
      console.error("Error presence:init:", err.message);
    }
  })();

  // disconnect
  socket.on("disconnect", async () => {
    try {
      await setOfflineSessionService(socket.id);

      // khi đã là bạn
      const friendIds = await getFriendIdsOfUser(userId);

      // khi không là bạn - cho phép người lạ nhắn tin nhau
      const convos = await Conversation.find({ members: userId })
        .select("members")
        .lean();

      const participants = convos
        .flatMap((c) =>
          c.members.filter((m) => m.toString() !== userId.toString())
        )
        .map((id) => id.toString());

      const notifyIds = [...new Set([...friendIds, ...participants])];

      if (notifyIds.length > 0) {
        io.to(notifyIds).emit("user_offline", userId);
      }

      console.log(`User ${userId} disconnected`);
    } catch (err) {
      console.error("Error presence:disconnect:", err.message);
    }
  });
}
