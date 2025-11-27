import User from "../models/user.js";

export const findAllUsers = () => User.find().select("-hashedPassword").lean();

export const findUserById = (id) =>
  User.findById(id).select("-hashedPassword").lean();

export const findUserByEmail = (email) => User.findOne({ email }).lean();

export const findUserByUsername = (username) =>
  User.findOne({ username }).lean();

export const findUserByDisplayName = (displayName) =>
  User.findOne({ displayName }).lean();

export const findUserByEmailForLogin = (email) =>
  User.findOne({ email }).select("+hashedPassword").lean();

export const insertUser = async (payload) => {
  const doc = await User.create(payload);
  return doc.toObject();
};

export const updateUser = (id, payload) =>
  User.findByIdAndUpdate(id, payload, { new: true })
    .select("-hashedPassword")
    .lean();

export const deleteUser = (id) => User.findByIdAndDelete(id).lean();
