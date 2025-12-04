import * as userRepository from "../repositories/userRepository.js";
import * as error from "../utils/error.js";
import bcrypt from "bcrypt";

export const getAllUsers = async () => {
  const users = await userRepository.findAllUsers();

  if (!users || users.length === 0)
    throw new error.NotFoundError("không tìm thấy danh sách users");

  return users;
};

export const getUserById = async (userId) => {
  const user = await userRepository.findUserById(userId);

  if (!user) throw new error.NotFoundError("không thể tìm thấy user này");

  return user;
};

export const getUserByEmail = async (userEmail) => {
  const user = await userRepository.findUserByEmail(userEmail);

  if (!user) throw new error.NotFoundError("không thể tìm thấy user này");

  return user;
};

export const getUserByUsername = async (username) => {
  const user = await userRepository.findUserByUsername(username);

  if (!user) throw new error.NotFoundError("không thể tìm thấy user này");

  return user;
};

export const getUserByDisplayName = async (userDisplayName) => {
  const user = await userRepository.findUserByDisplayName(userDisplayName);

  if (!user) throw new error.NotFoundError("không thể tìm thấy user này");

  return user;
};

export const createUser = async (payload) => {
  const {
    username,
    email,
    password,
    firstName,
    lastName,
    role,
    avatarUrl,
    coverImgUrl,
    bio,
  } = payload;

  if (!username || !email || !password || !firstName || !lastName)
    throw new error.BadRequestError("vui lòng điền đủ thông tin");

  const usernameDup = await userRepository.findUserByUsername(username);
  const emailDup = await userRepository.findUserByEmail(email);

  if (usernameDup || emailDup)
    throw new error.BadRequestError("user đã tồn tại");

  const hashedPassword = await bcrypt.hash(password, 12);
  const displayName = `${firstName} ${lastName}`.trim();

  return await userRepository.insertUser({
    username,
    email,
    hashedPassword,
    firstName,
    lastName,
    displayName,
    role: role || "user",
    avatarUrl,
    coverImgUrl,
    bio,
  });
};

export const modifyUser = async (userId, payload) => {
  const user = await userRepository.findUserById(userId);

  if (!user) throw new error.NotFoundError("user không tồn tại");

  const newUser = await userRepository.updateUser(userId, payload);

  return newUser;
};

export const removeUser = async (userId) => {
  const user = await userRepository.findUserById(userId);

  if (!user) throw new error.NotFoundError("user không tồn tại");

  await userRepository.deleteUser(userId);

  return true;
};
