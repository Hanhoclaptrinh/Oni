import FriendShip from "../models/friendship.js";

// check quan hệ
const relationQuery = (userA, userB) => ({
  $or: [
    { requester: userA, recipient: userB },
    { requester: userB, recipient: userA },
  ],
});

// tìm lời mời kết bạn
export const findFriendRequest = (friendshipId) =>
  FriendShip.findById(friendshipId);

// tìm quan hệ giữa 2 người để check trạng thái gửi
export const findRelation = (userA, userB) =>
  FriendShip.findOne({
    $or: [
      { requester: userA, recipient: userB },
      { requester: userB, recipient: userA },
    ],
  });

// check trạng thái đã trở thành bạn bè hay chưa
export const checkFriendStatus = (userA, userB) => {
  return FriendShip.findOne({
    $or: [
      { requester: userA, recipient: userB, status: "accepted" },
      { requester: userB, recipient: userA, status: "accepted" },
    ],
  });
};

// kiểm tra trạng thái chặn
export const checkBlocked = (userA, userB) =>
  FriendShip.findOne({
    ...relationQuery(userA, userB),
    isBlocked: true,
  }).lean();

// tạo lời mời kết bạn
export const createFriendRequest = (requesterId, recipientId) =>
  FriendShip.create({
    requester: requesterId,
    recipient: recipientId,
    status: "pending",
    actionUser: requesterId,
  });

// chấp nhận lời mời
export const acceptFriendRequest = (friendshipId, userId) =>
  FriendShip.findByIdAndUpdate(
    friendshipId,
    {
      status: "accepted",
      actionUser: userId,
      previousStatus: null,
      isBlocked: false,
      blockedBy: null,
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
  })
    .populate("requester", "username displayname avatar")
    .lean();

// list lời mời đã gửi
export const getSentRequests = (userId) =>
  FriendShip.find({
    requester: userId,
    status: "pending",
  })
    .populate("recipient", "username displayname avatar")
    .lean();

// list friends
export const findAllFriends = (userId) =>
  FriendShip.find({
    $or: [
      { requester: userId, status: "accepted" },
      { recipient: userId, status: "accepted" },
    ],
  })
    .populate([
      { path: "requester", select: "username displayname avatar" },
      { path: "recipient", select: "username displayname avatar" },
    ])
    .lean();

// unfriend
export const removeFriend = (userA, userB) =>
  FriendShip.findOneAndDelete({
    ...relationQuery(userA, userB),
    status: "accepted",
  });

// chặn bạn
export const blockUser = async (userA, userB) => {
  const relation = await FriendShip.findOne({
    $or: [
      { requester: userA, recipient: userB },
      { requester: userB, recipient: userA },
    ],
  });

  const previousStatus = relation ? relation.status : null;

  if (relation) {
    // chỉ update khi đã tồn tại
    return FriendShip.findByIdAndUpdate(
      relation._id,
      {
        status: "blocked",
        blockedBy: userA,
        isBlocked: true,
        previousStatus,
      },
      { new: true }
    );
  }

  // chưa có quan hệ -> tạo thủ công
  return FriendShip.create({
    requester: userA,
    recipient: userB,
    status: "blocked",
    blockedBy: userA,
    isBlocked: true,
    previousStatus,
    actionUser: userA,
  });
};

// mở chặn
export const unblockUser = async (userA, userB) => {
  const relation = await FriendShip.findOne(relationQuery(userA, userB));

  if (!relation) return null;
  if (relation.status !== "blocked")
    throw new Error("không phải trạng thái blocked");

  if (relation.previousStatus) {
    relation.status = relation.previousStatus;
    relation.previousStatus = null;
  } else {
    await FriendShip.deleteOne({ _id: relation._id });
    return true;
  }

  relation.blockedBy = null;
  relation.isBlocked = false;

  await relation.save();
  return relation.toObject();
};
