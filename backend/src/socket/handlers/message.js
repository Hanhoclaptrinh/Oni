import {
  sendMessageService,
  markMessagesAsSeenService,
  revokeMessageService,
  editMessageService,
} from "../../services/msgService.js";

export default function registerMessageHandler(io, socket) {
  console.log("message handler loaded for", socket.id);

  // gui tin nhan
  socket.on("send_message", async (payload) => {
    try {
      const { conversationId, tempId } = payload;
      const senderId = socket.userId; // lấy từ middleware

      if (!conversationId || !senderId) {
        console.log("Missing data", { conversationId, senderId });
        return;
      }

      if (!payload || !payload.conversationId) {
        socket.emit("error_message", "payload không hợp lệ");
        return;
      }

      const { message, members } = await sendMessageService(
        conversationId,
        senderId,
        payload
      );

      const m = message.toObject();

      // emit tin nhan den room
      const normalizedMsg = {
        ...m,
        _id: m._id.toString(),
        conversationId: m.conversationId.toString(),
        senderId: m.senderId.toString(),
        replyTo: m.replyTo ? m.replyTo.toString() : null,
        seenBy: (m.seenBy || []).map((id) => id.toString()),
        hiddenFor: (m.hiddenFor || []).map((id) => id.toString()),
        createdAt: m.createdAt.toISOString(),
        updatedAt: m.updatedAt.toISOString(),
        editedAt: m.editedAt ? m.editedAt.toISOString() : null,
        revokedAt: m.revokedAt ? m.revokedAt.toISOString() : null,
      };

      // ack
      socket.emit("msg:sent", {
        tempId,
        message: normalizedMsg,
      });

      io.to(conversationId).emit("new_message", normalizedMsg);

      // update convos list
      for (const memberId of members) {
        if (memberId.toString() === senderId.toString()) continue;

        io.to(memberId.toString()).emit("convos:update", {
          conversationId: conversationId.toString(),
          lastMessage: {
            _id: message._id.toString(),
            type: message.type,
            content: message.content,
            media: message.media ?? null,
            createdAt: message.createdAt,
            editedAt: message.editedAt,
            isMine: false,
          },
        });
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

  // chinh sua tin nhan
  socket.on("edit_message", async ({ msgId, content }) => {
    try {
      const userId = socket.userId;

      const msg = await editMessageService(msgId, content, userId);

      if (!msg) {
        console.log("tin nhan khong ton tai");
        return;
      }

      // emit trong room chat
      io.to(msg.conversationId.toString()).emit("msg:edited", {
        conversationId: msg.conversationId.toString(),
        msgId: msg._id.toString(),
        content: msg.content,
        editedAt: msg.editedAt,
      });

      // emit global update conversation list
      // for (const memberId of msg.members ?? []) {
      //   if (memberId.toString() === userId.toString()) continue;
      //   io.to(memberId.toString()).emit("convos:update", {
      //     conversationId: msg.conversationId.toString(),
      //     latestMessage: {
      //       _id: msg._id.toString(),
      //       content: msg.content,
      //       type: msg.type,
      //       senderId: msg.senderId.toString(),
      //       createdAt: msg.createdAt,
      //       editedAt: msg.editedAt,
      //       isMine: false,
      //     },
      //   });
      // }
    } catch (err) {
      console.error("Socket edit_message:", err.message);
    }
  });

  // thu hoi tin nhan
  socket.on("revoke_message", async ({ msgId }) => {
    try {
      const userId = socket.userId;

      const msg = await revokeMessageService(msgId, userId);
      if (!msg) {
        console.log("tin nhan khong ton tai");
        return;
      }

      io.to(msg.conversationId.toString()).emit("msg:revoked", {
        conversationId: msg.conversationId.toString(),
        msgId: msg._id.toString(),
        status: "revoked",
      });

      // emit global update conversation list
      // for (const memberId of msg.members ?? []) {
      //   if (memberId.toString() === userId.toString()) continue;
      //   io.to(memberId.toString()).emit("convos:update", {
      //     conversationId: msg.conversationId.toString(),
      //     latestMessage: {
      //       _id: msg._id.toString(),
      //       content: msg.content,
      //       type: msg.type,
      //       senderId: msg.senderId.toString(),
      //       createdAt: msg.createdAt,
      //       editedAt: msg.editedAt,
      //       isMine: false,
      //     },
      //   });
      // }
    } catch (err) {
      console.error("Socket revoke_message:", err.message);
    }
  });
}
