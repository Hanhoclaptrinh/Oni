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
    const userId = req.params.userId;

    if (!userId) throw new error.BadRequestError("thiếu id");

    const data = await userService.getUserById(userId);

    return res.status(200).json({
      success: true,
      message: "lấy user theo ID thành công",
      data,
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

export const getMeHandler = async (req, res, next) => {
  try {
    const stats = await userService.getUserStats(req.user._id);

    return res.status(200).json({
      success: true,
      message: "lấy user hiện tại thành công",
      data: { ...req.user, ...stats },
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
      coverImgUrl,
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
      coverImgUrl,
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
    const userId = req.params.userId;

    if (!userId) throw new error.BadRequestError("thiếu id");
    if (!Object.keys(req.body).length)
      throw new error.BadRequestError("body không được để trống");

    const updatedUser = await userService.modifyUser(userId, req.body);

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
    const userId = req.params.userId;

    if (!userId) throw new error.BadRequestError("thiếu id");

    await userService.removeUser(userId);

    return res.status(200).json({
      success: true,
      message: "xóa thành công user",
    });
  } catch (e) {
    next(e);
  }
};

export const updateMeHandler = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const body = req.body;

    if (!Object.keys(body).length) {
      throw new error.BadRequestError("dữ liệu không được để trống");
    }

    // ngăn chặn việc tự update role
    if (body.role) {
      delete body.role;
    }

    const updatedUser = await userService.modifyUser(userId, body);

    return res.status(200).json({
      success: true,
      message: "cập nhật hồ sơ thành công",
      data: updatedUser,
    });
  } catch (e) {
    next(e);
  }
};
