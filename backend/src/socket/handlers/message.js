import {
  sendMessageService,
  markMessagesAsSeenService,
} from "../../services/msgService.js";

export default function registerMessageHandler(io, socket) {
  console.log("message handler loaded for", socket.id);

  // gui tin nhan
  socket.on("send_message", async (payload) => {
    try {
      const { conversationId, type, content, fileUrl } = payload;
      const senderId = socket.userId; // lấy từ middleware

      if (!conversationId || !senderId) {
        console.log("thiếu dữ liệu tin nhắn");
      }

      // luu tin nhan vao db
      const { message, members } = await sendMessageService(
        conversationId,
        senderId,
        payload
      );

      console.log(
        `Message sent in conversation ${conversationId} by ${senderId}`
      );

      // emit tin nhan den room
      io.to(conversationId).emit("new_message", message);

      for (const memberId of members) {
        if (memberId.toString() === senderId.toString()) continue;

        io.to(memberId.toString()).emit("new_message_global", message);
      }
    } catch (err) {
      console.error("Socket send_message:", err.message);
      socket.emit("error_message", err.message);
    }
  });

  // danh dau da seen
  socket.on("seen_messages", async ({ conversationId }) => {
    const userId = socket.userId; // lấy từ middleware
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

  // typing
  socket.on("typing_start", ({ conversationId }) => {
    socket.to(conversationId).emit("user_typing", {
      conversationId,
      userId: socket.userId,
    });
  });

  socket.on("typing_end", ({ conversationId }) => {
    socket.to(conversationId).emit("user_stop_typing", {
      conversationId,
      userId: socket.userId,
    });
  });
}
