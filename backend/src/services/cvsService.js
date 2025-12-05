import * as cvsRepository from "../repositories/cvsRepository.js";
import * as error from "../utils/error.js";

export const createPrivateConversationService = async (
  senderId,
  recipientId
) => {
  if (!senderId) throw new error.BadRequestError("thiếu thông tin người gửi");

  if (!recipientId)
    throw new error.BadRequestError("thiếu thông tin người nhận");

  return await cvsRepository.createPrivateConversation(senderId, recipientId);
};

export const createGroupConversationService = async (creatorId, memberIds) => {
  if (!creatorId)
    throw new error.BadRequestError("thiếu thông tin người tạo nhóm");

  if (!memberIds) throw new error.BadRequestError("thiếu thông tin thành viên");

  if (!Array.isArray(memberIds) || memberIds.length === 0)
    throw new error.BadRequestError("nhóm không được rỗng");

  if (memberIds.length < 2)
    throw new error.BadRequestError("nhóm phải có ít nhất 3 thành viên");

  return await cvsRepository.createGroupConversation(creatorId, memberIds);
};

export const deleteConversationService = async (conversationId) => {
  const existingConversation = await cvsRepository.findConversationById(
    conversationId
  );

  if (!existingConversation)
    throw new error.NotFoundError("không tìm thấy cuộc hội thoại");

  await cvsRepository.deleteConversation(conversationId);

  return true;
};

export const verifyConversationMemberService = async (
  conversationId,
  userId
) => {
  const conversation = await cvsRepository.findConversationById(conversationId);
  if (!conversation) return false;

  return conversation.members.includes(userId);
};
