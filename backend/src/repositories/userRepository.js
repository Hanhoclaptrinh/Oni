import user from "../models/user.js";

export const findAllUsers = () => user.find().select("-hashedPassword").lean();

export const findUserById = (id) =>
  user.findById(id).select("-hashedPassword").lean();

export const findUserByEmail = (email) => user.findOne({ email }).lean();

export const findUserByUsername = (username) =>
  user.findOne({ username }).lean();

export const findUserByDisplayName = (displayName) =>
  user.findOne({ displayName }).lean();

export const findUserByEmailForLogin = (email) => user.findOne({ email }).select("+hashedPassword").lean();

export const insertUser = async (payload) => {
  const doc = await user.create(payload);
  return doc.toObject();
};

export const updateUser = (id, payload) =>
  user
    .findByIdAndUpdate(id, payload, { new: true })
    .select("-hashedPassword")
    .lean();

export const deleteUser = (id) => user.findByIdAndDelete(id).lean();
