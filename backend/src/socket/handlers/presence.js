import {
  createSocketSessionService,
  setOfflineSessionService,
} from "../../services/skssService.js";

export default function registerPresenceHandler(io, socket) {
  console.log("presence handler loaded for", socket.id);

  // user online
  socket.on("user_online", async (userId) => {
    try {
      if (!userId) return;

      socket.userId = userId;

      // join room riêng của user
      socket.join(userId);

      // lưu session vào DB
      await createSocketSessionService(userId, socket.id);

      console.log(`User ${userId} online via socket ${socket.id}`);

      // emit đến bạn bè
      // io.to(friendId).emit("friend_online", userId);
    } catch (err) {
      console.error("Error presence:user_online:", err.message);
    }
  });

  // user disconnect
  socket.on("disconnect", async () => {
    try {
      const userId = socket.userId;

      await setOfflineSessionService(socket.id);

      console.log(`User ${userId} disconnected`);

      // emit đến bạn bè
      // io.to(friendId).emit("friend_offline", userId);
    } catch (err) {
      console.error("Error presence:disconnect:", err.message);
    }
  });
}
