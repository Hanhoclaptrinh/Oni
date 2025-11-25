import * as userService from "../services/userService.js";
import * as error from "../utils/error.js";

export const getAllUsersHandler = async (req, res, next) => {
  try {
    const data = await userService.getAllUsers();
    return res.status(200).json({
      success: true,
      message: "lấy danh sách user thành công",
      data,
    });
  } catch (e) {
    next(e);
  }
};

export const getUserByIdHandler = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!id) throw new error.BadRequestError("thiếu id");

    const data = await userService.getUserById(id);

    return res.status(200).json({
      success: true,
      message: "lấy user theo ID thành công",
      data,
    });
  } catch (e) {
    next(e);
  }
};

export const getUserByEmailHandler = async (req, res, next) => {
  try {
    const { email } = req.query;

    if (!email) throw new error.BadRequestError("thiếu email");

    const data = await userService.getUserByEmail(email);

    return res.status(200).json({
      success: true,
      message: "lấy user theo email thành công",
      data,
    });
  } catch (e) {
    next(e);
  }
};

export const getUserByUsernameHandler = async (req, res, next) => {
  try {
    const { username } = req.query;

    if (!username) throw new error.BadRequestError("thiếu username");

    const data = await userService.getUserByUsername(username);

    return res.status(200).json({
      success: true,
      message: "lấy user theo username thành công",
      data,
    });
  } catch (e) {
    next(e);
  }
};

export const getUserByDisplayNameHandler = async (req, res, next) => {
  try {
    const { displayName } = req.query;

    if (!displayName) throw new error.BadRequestError("thiếu displayName");

    const data = await userService.getUserByDisplayName(displayName);

    return res.status(200).json({
      success: true,
      message: "lấy user theo displayName thành công",
      data,
    });
  } catch (e) {
    next(e);
  }
};

export const getMeHandler = async (req, res, next) => {
  try {
    return res.status(200).json({
      success: true,
      message: "lấy user hiện tại thành công",
      data: req.existingUser,
    });
  } catch (e) {
    next(e);
  }
};

export const createUserHandler = async (req, res, next) => {
  try {
    const {
      username,
      email,
      password,
      firstName,
      lastName,
      role,
      avatarUrl,
      avatarId,
      bio,
    } = req.body;

    if (!username || !email || !password || !firstName || !lastName)
      throw new error.BadRequestError("vui lòng điền đầy đủ thông tin");

    const user = await userService.createUser({
      username,
      email,
      password,
      firstName,
      lastName,
      role,
      avatarUrl,
      avatarId,
      bio,
    });

    return res.status(201).json({
      success: true,
      message: "tạo thành công user",
      data: user,
    });
  } catch (e) {
    next(e);
  }
};

export const updateUserHandler = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!id) throw new error.BadRequestError("thiếu id");
    if (!Object.keys(req.body).length)
      throw new error.BadRequestError("body không được để trống");

    const updatedUser = await userService.modifyUser(id, req.body);

    return res.status(200).json({
      success: true,
      message: "cập nhật thông tin user thành công",
      data: updatedUser,
    });
  } catch (e) {
    next(e);
  }
};

export const deleteUserHandler = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!id) throw new error.BadRequestError("thiếu id");

    await userService.removeUser(id);

    return res.status(200).json({
      success: true,
      message: "xóa thành công user",
    });
  } catch (e) {
    next(e);
  }
};

export const searchUserHandler = async (req, res, next) => {
  try {
    const { email, username, displayName } = req.query;

    if (!email && !username && !displayName) {
      throw new error.BadRequestError("thiếu query search");
    }

    let user;

    if (email) {
      user = await userService.getUserByEmail(email);
    } else if (username) {
      user = await userService.getUserByUsername(username);
    } else if (displayName) {
      user = await userService.getUserByDisplayName(displayName);
    }

    return res.status(200).json({
      success: true,
      message: "tìm user thành công",
      data: user,
    });
  } catch (e) {
    next(e);
  }
};
