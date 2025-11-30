import * as frsRepository from "../repositories/frsRepository.js";
import * as error from "../utils/error.js";

const compareId = (id1, id2) => id1.toString() === id2.toString();

// gửi lời mời kb
export const createFriendRequestService = async (requesterId, recipientId) => {
  if (compareId(requesterId, recipientId))
    throw new error.BadRequestError("không thể tự gửi cho chính mình");

  const existing = await frsRepository.findRelation(requesterId, recipientId);

  if (existing) {
    // xử lý block
    if (existing.isBlocked) {
      if (compareId(existing.blockedBy, requesterId))
        throw new error.ForbiddenError("bạn đã chặn người này");
      else throw new error.ForbiddenError("bạn đã bị người này chặn");
    }

    // đang chờ xác nhận
    if (existing.status === "pending")
      throw new error.BadRequestError("yêu cầu đang chờ xử lý");

    // đã là bạn
    if (existing.status === "accepted")
      throw new error.BadRequestError("hai bạn đã là bạn bè");
  }

  return frsRepository.createFriendRequest(requesterId, recipientId);
};

// chấp nhận lời mời kb
export const acceptFriendRequestService = async (friendshipId, userId) => {
  const friendship = await frsRepository.findFriendRequest(friendshipId);

  if (!friendship) throw new error.NotFoundError("không tìm thấy lời mời");

  if (friendship.isBlocked)
    throw new error.ForbiddenError("không thể chấp nhận do một bên đã block");

  if (friendship.status !== "pending")
    throw new error.BadRequestError("trạng thái không hợp lệ để accept");

  if (!compareId(friendship.recipient, userId))
    throw new error.ForbiddenError(
      "không thể chấp nhận lời mời không phải của mình"
    );

  return frsRepository.acceptFriendRequest(friendshipId, userId);
};

// từ chối lời mời kb
export const declineFriendRequestService = async (friendshipId, userId) => {
  const friendship = await frsRepository.findFriendRequest(friendshipId);

  if (!friendship) throw new error.NotFoundError("không tìm thấy lời mời");

  if (!compareId(friendship.recipient, userId))
    throw new error.ForbiddenError(
      "không thể từ chối lời mời không thuộc về mình"
    );

  await frsRepository.declineFriendRequest(friendshipId);
  return true;
};

// hủy lời mời đã gửi
export const cancelFriendRequestService = async (friendshipId, userId) => {
  const friendship = await frsRepository.findFriendRequest(friendshipId);

  if (!friendship) throw new error.NotFoundError("không tìm thấy lời mời");

  if (!compareId(friendship.requester, userId))
    throw new error.ForbiddenError("không thể hủy yêu cầu không do bạn gửi");

  await frsRepository.cancelFriendRequest(friendshipId);
  return true;
};

// danh sách
export const getReceivedRequestsService = (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");
  return frsRepository.getReceivedRequests(userId);
};

export const getSentRequestsService = (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");
  return frsRepository.getSentRequests(userId);
};

export const getAllFriendsService = (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");
  return frsRepository.findAllFriends(userId);
};

// hủy kết bạn
export const removeFriendService = async (userId, friendId) => {
  const removed = await frsRepository.removeFriend(userId, friendId);

  if (!removed) throw new error.NotFoundError("hai bạn chưa phải bạn bè");

  return true;
};

// chặn
export const blockUserService = async (userA, userB) => {
  const relation = await frsRepository.findRelation(userA, userB);

  if (relation && relation.isBlocked) {
    throw new error.BadRequestError("đã block trước đó rồi");
  }

  return await frsRepository.blockUser(userA, userB);
};

// bỏ chặn
export const unblockUserService = async (userA, userB) => {
  const result = await frsRepository.unblockUser(userA, userB);

  if (!result) throw new error.BadRequestError("không tồn tại block để mở");

  return result;
};

// check block 2 chiều
export const checkBlockedService = async (userA, userB) => {
  const relation = await frsRepository.checkBlocked(userA, userB);

  if (!relation) return null;

  if (compareId(relation.blockedBy, userA))
    throw new error.ForbiddenError("bạn đã bị người này chặn");

  throw new error.ForbiddenError("bạn đã chặn người này");
};
