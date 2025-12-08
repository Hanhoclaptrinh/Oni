import { verifyConversationMemberService } from "../../services/cvsService.js";

export default function registerConversationHandler(io, socket) {
  console.log("conversation handler loaded for", socket.id);

  // join conversation
  socket.on("join_conversation", async (conversationId) => {
    try {
      const userId = socket.userId;
      if (!conversationId) return;

      const isMember = await verifyConversationMemberService(
        conversationId,
        userId
      );

      if (!isMember) {
        console.log(
          `User ${userId} tried to join ${conversationId} but is not member`
        );
        return socket.emit("error_join", "not_member");
      }

      socket.join(conversationId);

      socket.emit("joined_conversation", conversationId);
      console.log(`User ${userId} joined room ${conversationId}`);
    } catch (err) {
      console.error("join_conversation:", err.message);
      socket.emit("error_join", err.message);
    }
  });

  // leave conversation
  socket.on("leave_conversation", (conversationId) => {
    try {
      const userId = socket.userId;
      if (!conversationId) return;

      socket.leave(conversationId);

      socket.emit("left_conversation", conversationId);
      console.log(`User ${userId} left conversation ${conversationId}`);
    } catch (err) {
      console.error("leave_conversation:", err.message);
    }
  });
}
