import {
  sendMessageService,
  markMessagesAsSeenService,
} from "../../services/msgService";

export default function registerMessageHandler(io, socket) {
  console.log("message handler loaded for", socket.id);

  // gui tin nhan
  socket.on("send_message", async (payload) => {
    try {
      const { conversationId, senderId, type, content, fileUrl } = payload;

      if (!conversationId || !senderId) {
        return socket.emit("error_message", "thiếu dữ liệu tin nhắn");
      }

      // luu tin nhan vao db
      const message = await sendMessageService(conversationId, senderId, {
        type,
        content,
        fileUrl,
      });

      console.log(
        `Message sent in conversation ${conversationId} by ${senderId}`
      );

      // emit tin nhan den room
      io.to(conversationId).emit("new_message", message);
    } catch (err) {
      console.error("Socket send_message:", err.message);
      socket.emit("error_message", err.message);
    }
  });

  // danh dau da seen
  socket.on("seen_messages", async ({ conversationId, userId }) => {
    try {
      if (!conversationId || !userId) return;

      await markMessagesAsSeenService(conversationId, userId);

      // emit cho moi nguoi biet user da seen
      io.to(conversationId).emit("messages_seen", {
        conversationId,
        userId,
      });

      console.log(
        `User ${userId} marked messages as seen in ${conversationId}`
      );
    } catch (err) {
      console.error("Socket seen_messages:", err.message);
    }
  });
}
