import * as msgRepository from "../repositories/msgRepository.js";
import * as error from "../utils/error.js";

export const getMessagesService = async (conversationId) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");

  return await msgRepository.getMessages(conversationId);
};

export const sendMessageService = async (conversationId, senderId, payload) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");

  if (!senderId) throw new error.BadRequestError("thiếu id người gửi tin nhắn");

  if (!payload.content && !payload.fileUrl)
    throw new BadRequestError("tin nhắn không thể rỗng");

  const msg = await msgRepository.sendMessage(
    conversationId,
    senderId,
    payload
  );

  return msg;
};

export const markMessagesAsSeenService = async (conversationId, userId) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");

  if (!userId) throw new error.BadRequestError("thiếu id người đọc");

  return await msgRepository.markMessagesAsSeen(conversationId, userId);
};

export const deleteMessageService = async (msgId) => {
  if (!msgId) throw new error.BadRequestError("thiếu id tin nhắn");

  await msgRepository.deleteMessage(msgId);

  return true;
};
