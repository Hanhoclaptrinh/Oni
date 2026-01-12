import { msgService } from "@bGV2aW5oaGFu/core-engine";

export const getMessagesHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { conversationId } = req.params;
    const { before, limit } = req.query;

    const result = await msgService.getMessagesService(
      conversationId,
      userId,
      before || null,
      Number(limit) || 50
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
    const { type, content, media } = req.body;
    const payload = { type, content, media };

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

export const deleteMessageForMeHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { msgId } = req.params;

    await msgService.deleteMessageForMeService(msgId, userId);

    return res.status(204).end();
  } catch (e) {
    next(e);
  }
};
