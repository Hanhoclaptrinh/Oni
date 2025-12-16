import * as msgService from "../services/msgService.js";

export const getMessagesHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { conversationId } = req.params;
    const { before, limit } = req.query;

    const result = await msgService.getMessagesService(
      conversationId,
      userId,
      before || null,
      Number(limit) || 30
    );

    return res.status(200).json({
      success: true,
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const sendMessageHandler = async (req, res, next) => {
  try {
    const senderId = req.user.id;
    const { conversationId } = req.params;
    const { type, content, fileUrl } = req.body;
    const payload = { type, content, fileUrl };

    if (!content && !fileUrl) {
      return res.status(400).json({
        success: false,
        message: "tin nhắn rỗng không gửi được",
      });
    }

    const result = await msgService.sendMessageService(
      conversationId,
      senderId,
      payload
    );

    return res.status(200).json({
      success: true,
      message: "gửi tin nhắn thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const markMessagesAsSeenHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { conversationId } = req.params;

    await msgService.markMessagesAsSeenService(conversationId, userId);

    return res.status(200).json({
      success: true,
      message: "đã xem",
    });
  } catch (e) {
    next(e);
  }
};

export const deleteMessageHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { msgId } = req.params;

    await msgService.deleteMessageService(msgId, userId);

    return res.status(200).json({
      success: true,
      message: "xóa tin nhắn thành công",
    });
  } catch (e) {
    next(e);
  }
};
