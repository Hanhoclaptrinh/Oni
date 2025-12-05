import * as cvsService from "../services/cvsService.js";

export const getMyConversationsHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const data = await cvsService.getMyConversationsService(userId);

    return res.status(200).json({
      success: true,
      message: "lấy danh sách hội thoại thành công",
      data,
    });
  } catch (e) {
    next(e);
  }
};

export const createPrivateConversationHandler = async (req, res, next) => {
  try {
    const senderId = req.user.id;
    const { recipientId } = req.body;

    const result = await cvsService.createPrivateConversationService(
      senderId,
      recipientId
    );

    return res.status(201).json({
      success: true,
      message: "tạo cuộc trò chuyện riêng tư thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const createGroupConversationHandler = async (req, res, next) => {
  try {
    const creatorId = req.user.id;
    const { memberIds } = req.body;

    const result = await cvsService.createGroupConversationService(
      creatorId,
      memberIds
    );

    return res.status(201).json({
      success: true,
      message: "tạo cuộc hội thoại nhóm thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const deleteConversationHandler = async (req, res, next) => {
  try {
    const { conversationId } = req.params;

    await cvsService.deleteConversationService(conversationId);

    return res.status(200).json({
      success: true,
      message: "xóa cuộc hội thoại thành công",
    });
  } catch (e) {
    next(e);
  }
};
