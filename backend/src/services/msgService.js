import * as msgRepository from "../repositories/msgRepository.js";
import * as cvsRepository from "../repositories/cvsRepository.js";
import * as frsService from "../services/frsService.js";
import * as error from "../utils/error.js";

// list lịch sử chat - 50 tin
export const getMessagesService = async (
  conversationId,
  skip = 0,
  limit = 50
) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");

  return msgRepository.getMessages(conversationId, skip, limit);
};

// gửi tin nhắn
export const sendMessageService = async (conversationId, senderId, payload) => {
  // validate
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");
  if (!senderId) throw new error.BadRequestError("thiếu id người gửi");
  if (!payload.content && !payload.fileUrl)
    throw new error.BadRequestError("tin nhắn không thể rỗng");

  const conversation = await cvsRepository.findConversationById(conversationId);
  if (!conversation) throw new error.NotFoundError("hội thoại không tồn tại");

  // chat nhóm - kiểm tra là thành viên trong nhóm
  const isMember = conversation.members
    .map((id) => id.toString())
    .includes(senderId.toString());

  if (!isMember)
    throw new error.ForbiddenError("bạn không thuộc hội thoại này");

  // chat riêng - check block
  if (conversation.type === "private") {
    const [userA, userB] = conversation.members;

    if (userA && userB) {
      await frsService.checkBlockedService(userA.toString(), userB.toString());
    }
  }

  // có thể chat trong nhóm chung dù có block
  return await msgRepository.sendMessage(conversationId, senderId, payload);
};

// đánh dấu đã xem
export const markMessagesAsSeenService = async (conversationId, userId) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");
  if (!userId) throw new error.BadRequestError("thiếu id người đọc");

  return msgRepository.markMessagesAsSeen(conversationId, userId);
};

// xóa tin nhắn - thu hồi tin nhắn != xóa 1 chiều
export const deleteMessageService = async (msgId, userId) => {
  if (!msgId) throw new error.BadRequestError("thiếu id tin nhắn");

  const msg = await msgRepository.getMessageById(msgId);

  if (!msg) throw new error.NotFoundError("tin nhắn không tồn tại");

  // chỉ người gửi được xóa
  if (msg.sender.toString() !== userId)
    throw new error.ForbiddenError("bạn không có quyền xóa tin nhắn này");

  await msgRepository.deleteMessage(msgId);
  return true;
};
