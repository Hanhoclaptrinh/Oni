import {
  createSocketSessionService,
  setOfflineSessionService,
} from "../../services/skssService.js";

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

      console.log(`User ${userId} online via socket ${socket.id}`);

      // emit cho bạn bè
      // io.to(friendId).emit("friend_online", userId);
    } catch (err) {
      console.error("Error presence:init:", err.message);
    }
  })();

  // disconnect
  socket.on("disconnect", async () => {
    try {
      await setOfflineSessionService(socket.id);

      console.log(`User ${userId} disconnected`);

      // emit cho bạn bè
      // io.to(friendId).emit("friend_offline", userId);
    } catch (err) {
      console.error("Error presence:disconnect:", err.message);
    }
  });
}
