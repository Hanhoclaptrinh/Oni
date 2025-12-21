import * as msgRepository from "../repositories/msgRepository.js";
import * as cvsRepository from "../repositories/cvsRepository.js";
import * as frsService from "../services/frsService.js";
import * as error from "../utils/error.js";

// list lịch sử chat - 50 tin
export const getMessagesService = async (
  conversationId,
  userId,
  beforeMessageId = null,
  limit = 50
) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");

  const conversation = await cvsRepository.findConversationById(conversationId);
  if (!conversation) throw new error.NotFoundError("hội thoại không tồn tại");

  const isMember = conversation.members
    .map((id) => id.toString())
    .includes(userId.toString());

  if (!isMember) throw new error.ForbiddenError("không có quyền xem hội thoại");

  return msgRepository.getMessages(
    conversationId,
    userId,
    beforeMessageId,
    limit
  );
};

// gửi tin nhắn
export const sendMessageService = async (conversationId, senderId, payload) => {
  // validate
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");
  if (!senderId) throw new error.BadRequestError("thiếu id người gửi");

  if (payload.type === "text" && !payload.content)
    throw new error.BadRequestError("tin nhắn text không được rỗng");

  if (payload.type !== "text" && !payload.fileUrl)
    throw new error.BadRequestError("tin nhắn file phải có fileUrl");

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
  const message = await msgRepository.sendMessage(
    conversationId,
    senderId,
    payload
  );

  return {
    message,
    members: conversation.members,
    conversationId,
  };
};

// đánh dấu đã xem
export const markMessagesAsSeenService = async (conversationId, userId) => {
  if (!conversationId) throw new error.BadRequestError("thiếu id hội thoại");
  if (!userId) throw new error.BadRequestError("thiếu id người đọc");

  return msgRepository.markMessagesAsSeen(conversationId, userId);
};

// chinh sua noi dung tin nhan
export const editMessageService = async (msgId, content, userId) => {
  if (!msgId) {
    throw new error.BadRequestError("thiếu id tin nhắn");
  }

  if (!content || !content.trim()) {
    throw new error.BadRequestError("nội dung không hợp lệ");
  }

  const updatedMsg = await msgRepository.editMessage(
    msgId,
    userId,
    content.trim()
  );

  if (!updatedMsg) {
    throw new error.ForbiddenError(
      "không tồn tại tin nhắn hoặc không có quyền chỉnh sửa"
    );
  }

  return updatedMsg;
};

// xoa tin nhan 1 chieu
export const deleteMessageForMeService = async (msgId, userId) => {
  const msg = await msgRepository.findMsgById(msgId);

  if (!msg) throw new error.BadRequestError("không tim thấy tin nhắn");

  await msgRepository.deleteMessageForMe(msgId, userId);

  return true;
};

// thu hoi tin nhan - xoa 2 chieu
export const revokeMessageService = async (msgId, userId) => {
  const msg = await msgRepository.findMsgById(msgId);

  if (!msg) throw new error.NotFoundError("không tim thấy tin nhắn");

  if (msg.senderId.toString() !== userId.toString())
    throw new error.ForbiddenError("chỉ người gửi mới được thu hồi");

  msg.status = "revoked";
  msg.revokedAt = new Date();
  msg.content = null;
  msg.fileUrl = null;

  return await msgRepository.revokeMessage(msgId);
};

// tra loi tin nhan
export const replyToMessageService = async (
  conversationId,
  msgId,
  userId,
  payload
) => {
  const oMsg = await msgRepository.findOriginalMsg(conversationId, msgId);

  if (!oMsg) throw new error.BadRequestError("không tim thấy tin nhắn");

  return await msgRepository.replyToMessage(
    conversationId,
    msgId,
    userId,
    payload
  );
};
