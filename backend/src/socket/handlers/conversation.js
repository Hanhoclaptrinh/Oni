import { verifyConversationMemberService } from "../../services/cvsService.js";

export default function registerConversationHandler(io, socket) {
  console.log("conversation handler loaded for", socket.id);

  // tham gia hoi thoai
  socket.on("join_conversation", async (conversationId) => {
    try {
      const userId = socket.userId;
      if (!conversationId || !userId) return;

      // kiem tra user co thuoc conversation nay khong
      const isMember = await verifyConversationMemberService(
        conversationId,
        userId
      );

      if (!isMember) {
        console.log(
          `User ${userId} tried to join conversation ${conversationId} but is not a member`
        );
        return;
      }

      socket.join(conversationId);

      console.log(`User ${userId} joined conversation room ${conversationId}`);

      // emit cho client
      socket.emit("joined_conversation", conversationId);
    } catch (err) {
      console.error("Error join_conversation:", err.message);
    }
  });

  // roi hoi thoai
  socket.on("leave_conversation", (conversationId) => {
    try {
      const userId = socket.userId;
      if (!conversationId || !userId) return;

      socket.leave(conversationId);

      console.log(`User ${userId} left conversation ${conversationId}`);
    } catch (err) {
      console.error("Error leave_conversation:", err.message);
    }
  });
}
