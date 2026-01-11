import Post from "../models/post.js";
import mongoose from "mongoose";

// tao bai viet
export const createPost = async (payload) => {
  return Post.create(payload);
};

// tim kiem bai viet
export const findPostById = async (id) => {
  if (!mongoose.Types.ObjectId.isValid(id)) return null;
  return Post.findOne({ _id: id, isDeleted: false });
};

// lay danh sach bai viet
// lay 10 bai viet 1 lan
export const getFeed = ({ page = 1, limit = 10 }) => {
  return Post.find({
    isDeleted: false,
    visibility: "public",
  })
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(limit)
    .populate("authorId", "displayName avatarUrl");
};

// chinh sua bai viet
export const updatePost = (postId, data) => {
  if (!mongoose.Types.ObjectId.isValid(postId)) return null; // khhong cho chinh sua nhung bai viet da bi xoa

  return Post.findOneAndUpdate(
    { _id: postId, isDeleted: false },
    { ...data, isEdited: true },
    { new: true }
  );
};

// xoa bai viet - xoa mem
export const softDeletePost = (postId, userId) => {
  return Post.findOneAndUpdate(
    { _id: postId, isDeleted: false }, // tim bai viet chua bi xoa
    {
      isDeleted: true, // set flag lai cho UI render
      deletedAt: new Date(),
      deletedBy: userId,
    },
    { new: true }
  );
};

// xoa cung - xoa vinh vien bai viet
// chi admin moi duoc xoa cung
export const hardDeletePost = (postId) => {
  return Post.deleteOne({ _id: postId });
};
