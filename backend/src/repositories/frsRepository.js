import FriendShip from "../models/friendship.js";

// tìm lời mời kết bạn
export const findFriendRequest = (friendshipId) =>
  FriendShip.findById(friendshipId);

// check trạng thái đã trở thành bạn bè hay chưa
export const checkFriendStatus = (userA, userB) => {
  return FriendShip.findOne({
    $or: [
      { requester: userA, recipient: userB, status: "accepted" },
      { requester: userB, recipient: userA, status: "accepted" },
    ],
  });
};

// tạo lời mời kết bạn
export const createFriendRequest = (requesterId, recipientId) =>
  FriendShip.create({
    requester: requesterId,
    recipient: recipientId,
    status: "pending",
    actionUser: requesterId,
  });

// tìm quan hệ giữa 2 người để check trạng thái gửi
export const findRelation = (userA, userB) =>
  FriendShip.findOne({
    $or: [
      { requester: userA, recipient: userB },
      { requester: userB, recipient: userA },
    ],
  });

// chấp nhận lời mời
export const acceptFriendRequest = (friendshipId, userId) =>
  FriendShip.findByIdAndUpdate(
    friendshipId,
    {
      status: "accepted",
      actionUser: userId,
    },
    { new: true }
  );

// từ chối lời mời
export const declineFriendRequest = (friendshipId) =>
  FriendShip.findByIdAndDelete(friendshipId);

// hủy lời mời đã gửi
export const cancelFriendRequest = (friendshipId) =>
  FriendShip.findByIdAndDelete(friendshipId);

// list lời mời đã nhận
export const getReceivedRequests = (userId) =>
  FriendShip.find({
    recipient: userId,
    status: "pending",
  }).populate("requester", "username displayname avatar");

// list lời mời đã gửi
export const getSentRequests = (userId) =>
  FriendShip.find({
    requester: userId,
    status: "pending",
  }).populate("recipient", "username displayname avatar");

// list friends
export const findAllFriends = (userId) => {
  return FriendShip.find({
    $or: [
      { requester: userId, status: "accepted" },
      { recipient: userId, status: "accepted" },
    ],
  }).populate([
    { path: "requester", select: "username displayname avatar" },
    { path: "recipient", select: "username displayname avatar" },
  ]);
};

// unfriend
export const removeFriend = (userA, userB) => {
  return FriendShip.findOneAndDelete({
    $or: [
      { requester: userA, recipient: userB, status: "accepted" },
      { requester: userB, recipient: userA, status: "accepted" },
    ],
  });
};
