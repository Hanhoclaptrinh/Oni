import * as frsService from "../services/frsService.js";

export const createFriendRequestHandler = async (req, res, next) => {
  try {
    const requesterId = req.user.id;
    const { recipientId } = req.body;

    if (!recipientId) {
      return res.status(400).json({
        success: false,
        message: "thiếu thông tin người nhận",
      });
    }

    const result = await frsService.createFriendRequestService(
      requesterId,
      recipientId
    );

    return res.status(200).json({
      success: true,
      message: "gửi yêu cầu kết bạn thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const acceptFriendRequestHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const friendshipId = req.params.id;

    if (!friendshipId) {
      return res.status(400).json({
        success: false,
        message: "thiếu id lời mời kết bạn",
      });
    }

    const result = await frsService.acceptFriendRequestService(
      friendshipId,
      userId
    );

    return res.status(200).json({
      success: true,
      message: "đã chấp nhận yêu cầu kết bạn",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const declineFriendRequestHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const friendshipId = req.params.id;

    if (!friendshipId) {
      return res.status(400).json({
        success: false,
        message: "thiếu id lời mời kết bạn",
      });
    }

    await frsService.declineFriendRequestService(friendshipId, userId);

    return res.status(200).json({
      success: true,
      message: "đã từ chối lời mời kết bạn",
    });
  } catch (e) {
    next(e);
  }
};

export const cancelFriendRequestHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const friendshipId = req.params.id;

    if (!friendshipId) {
      return res.status(400).json({
        success: false,
        message: "thiếu id lời mời kết bạn",
      });
    }

    await frsService.cancelFriendRequestService(friendshipId, userId);

    return res.status(200).json({
      success: true,
      message: "đã xóa yêu cầu kết bạn",
    });
  } catch (e) {
    next(e);
  }
};

export const getReceivedRequestsHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const result = await frsService.getReceivedRequestsService(userId);

    return res.status(200).json({
      success: true,
      message: "list yêu cầu kết bạn đã nhận",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const getSentRequestsHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const result = await frsService.getSentRequestsService(userId);

    return res.status(200).json({
      success: true,
      message: "list yêu cầu kết bạn đã gửi",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const getAllFriendsHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;

    const result = await frsService.getAllFriendsService(userId);

    return res.status(200).json({
      success: true,
      message: "lấy danh sách bạn bè thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const removeFriendHandler = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const friendId = req.params.id;

    if (!friendId) {
      return res.status(400).json({
        success: false,
        message: "thiếu id bạn bè",
      });
    }

    await frsService.removeFriendService(userId, friendId);

    return res.status(200).json({
      success: true,
      message: "đã hủy kết bạn",
    });
  } catch (e) {
    next(e);
  }
};
