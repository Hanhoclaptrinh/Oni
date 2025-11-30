import Conversation from "../models/conversation.js";

export const findConversationById = (conversationId) =>
  Conversation.findById(conversationId).lean();

// tạo private conversation
export const createPrivateConversation = async (senderId, recipientId) => {
  // hash chống trùng lặp hội thoại
  // A nhắn B -> sinh cặp A_B
  // B nhắn A -> sinh cặp B_A -> sai
  // sau khi hash và sort cả 2 hội thoại đều về dạng A_B
  const memberHash = [senderId, recipientId]
    .map((id) => id.toString())
    .sort()
    .join("_");

  // check đã có chưa
  const existing = await Conversation.findOne({ memberHash });
  if (existing) return existing;

  return Conversation.create({
    type: "private",
    members: [senderId, recipientId],
    memberHash,
  });
};

// tạo nhóm
export const createGroupConversation = (creatorId, memberIds = []) =>
  Conversation.create({
    type: "group",
    members: [creatorId, ...memberIds],
    createdBy: creatorId,
  });

// xóa cuộc hội thoại
export const deleteConversation = (conversationId) =>
  Conversation.findByIdAndDelete(conversationId);
