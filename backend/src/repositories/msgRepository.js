import Message from "../models/message.js";
import Conversation from "../models/conversation.js";

// lấy lịch sử chat
export const getMessages = (
  conversationId,
  beforeMessageId = null,
  limit = 30
) => {
  const query = { conversationId };

  if (beforeMessageId) {
    query._id = { $lt: beforeMessageId };
  }

  return Message.find(query).sort({ _id: -1 }).limit(limit).lean();
};

// gửi tin nhắn
export const sendMessage = async (conversationId, senderId, payload) => {
  const message = await Message.create({
    conversationId,
    senderId,
    type: payload.type || "text",
    content: payload.content || null,
    fileUrl: payload.fileUrl || null,
  });

  await Conversation.findByIdAndUpdate(conversationId, {
    latestMessage: message._id,
  });

  return message;
};

// seen by
export const markMessagesAsSeen = async (conversationId, userId) =>
  Message.updateMany(
    {
      conversationId,
      senderId: { $ne: userId },
      seenBy: { $ne: userId },
    },
    { $addToSet: { seenBy: userId } } // tránh trùng khi seen nhiều lần
  );

// xóa tin nhắn
export const deleteMessage = (msgId) => Message.findByIdAndDelete(msgId);
