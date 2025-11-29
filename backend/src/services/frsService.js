import * as frsRepository from "../repositories/frsRepository.js";
import * as error from "../utils/error.js";

export const createFriendRequestService = async (requesterId, recipientId) => {
  // chặn việc gửi cho chính mình
  if (requesterId === recipientId)
    throw new error.BadRequestError("không thể tự gửi cho chính bản thân");

  const existing = await frsRepository.findRelation(requesterId, recipientId);

  if (existing) {
    if (existing.status === "pending")
      throw new error.BadRequestError("đang chờ xử lý");

    if (existing.status === "accepted")
      throw new error.BadRequestError("hiện đã là bạn bè");

    if (existing.status === "blocked")
      throw new error.BadRequestError("không thể gửi yêu cầu, đã bị block");
  }

  const result = await frsRepository.createFriendRequest(
    requesterId,
    recipientId
  );

  return result;
};

export const acceptFriendRequestService = async (friendshipId, userId) => {
  const friendship = await frsRepository.findFriendRequest(friendshipId);

  if (!friendship) throw new error.NotFoundError("không tìm thấy lời mời");

  if (friendship.status !== "pending")
    throw new error.BadRequestError("trạng thái không hợp lệ để accept");

  if (friendship.status === "blocked")
    throw new error.BadRequestError("không thể accept do 1 trong 2 đã block");

  // người nhận không được chấp nhận chính yêu cầu mình gửi
  if (friendship.recipient.toString() !== userId) {
    throw new error.ForbiddenError(
      "không thể accept lời mời không phải của mình"
    );
  }

  const result = await frsRepository.acceptFriendRequest(friendshipId, userId);

  return result;
};

export const declineFriendRequestService = async (friendshipId, userId) => {
  const friendship = await frsRepository.findFriendRequest(friendshipId);

  if (!friendship) throw new error.NotFoundError("không tìm thấy lời mời");

  // chỉ người nhận mới có thể từ chối yêu cầu
  if (friendship.recipient.toString() !== userId)
    throw new error.ForbiddenError(
      "không thể từ chối lời mời không thuộc về mình"
    );

  await frsRepository.declineFriendRequest(friendshipId);

  return true;
};

export const cancelFriendRequestService = async (friendshipId, userId) => {
  const friendship = await frsRepository.findFriendRequest(friendshipId);

  if (!friendship) throw new error.NotFoundError("không tìm thấy lời mời");

  // chỉ người gửi mới có thể hủy yêu cầu
  if (friendship.requester.toString() !== userId)
    throw new error.ForbiddenError(
      "không thể hủy yêu cầu không phải do mình gửi"
    );

  await frsRepository.cancelFriendRequest(friendshipId);

  return true;
};

export const getReceivedRequestsService = async (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");

  const result = await frsRepository.getReceivedRequests(userId);

  return result;
};

export const getSentRequestsService = async (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");

  const result = await frsRepository.getSentRequests(userId);

  return result;
};

export const getAllFriendsService = async (userId) => {
  if (!userId) throw new error.BadRequestError("thiếu userId");

  const result = await frsRepository.findAllFriends(userId);

  if (!result) throw new error.NotFoundError("không có bạn bè nào");

  return result;
};

export const removeFriendService = async (userId, friendId) => {
  const result = await frsRepository.removeFriend(userId, friendId);

  if (!result) throw new error.NotFoundError("hai bạn chưa phải bạn bè");

  return true;
};
