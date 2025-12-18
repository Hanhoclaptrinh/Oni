import * as msgService from "../services/msgService.js";
import Conversation from "../models/conversation.js";
import * as error from "../utils/error.js";

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

export const revokeMessageHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { msgId } = req.params;

    const msg = await msgService.revokeMessageService(msgId, userId);
    if (!msg) {
      throw new error.NotFoundError("tin nhắn không tồn tại");
    }

    const conversation = await Conversation.findById(msg.conversationId);
    if (!conversation) {
      throw new error.NotFoundError("hội thoại không tồn tại");
    }

    req.io.to(msg.conversationId).emit("msg:revoke", {
      conversationId: msg.conversationId,
      msgId: msg._id,
    });

    return res.status(204).end();
  } catch (e) {
    next(e);
  }
};
