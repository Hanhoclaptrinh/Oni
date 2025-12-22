import Message from "../models/message.js";
import Conversation from "../models/conversation.js";

// tim tin nhan theo id
export const findMsgById = (msgId) => Message.findById(msgId);

// tim tin nhan goc
export const findOriginalMsg = async (conversationId, msgId) => {
  return await Message.findOne({
    conversationId,
    _id: msgId,
  }).select("senderId content type fileUrl");
};

// lấy lịch sử chat
export const getMessages = (
  conversationId,
  userId,
  beforeMessageId = null,
  limit = 50
) => {
  const query = { conversationId, hiddenFor: { $ne: userId } };

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
    replyTo: payload.replyTo || null,
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

// chinh sua noi dung tin nhan
export const editMessage = async (msgId, userId, content) => {
  return await Message.findOneAndUpdate(
    {
      _id: msgId,
      senderId: userId,
      deletedAt: null,
    },
    {
      content,
      editedAt: new Date(),
    },
    { new: true }
  );
};

// xoa tin nhan 1 chieu
export const deleteMessageForMe = async (msgId, userId) => {
  return await Message.findByIdAndUpdate(
    msgId,
    {
      $addToSet: { hiddenFor: userId },
    },
    { new: true }
  );
};

// thu hoi tin nhan - xoa 2 chieu
export const revokeMessage = async (msgId) => {
  return await Message.findByIdAndUpdate(
    msgId,
    {
      status: "revoked",
      revokedAt: new Date(),
      content: null,
      fileUrl: null,
    },
    { new: true }
  );
};
