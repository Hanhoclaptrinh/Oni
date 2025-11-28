import * as authService from "../services/authService.js";
import * as error from "../utils/error.js";

export const signUpHandler = async (req, res, next) => {
  try {
    const { username, email, password, firstName, lastName } = req.body;

    if (!username || !email || !password || !firstName || !lastName)
      throw new error.BadRequestError("vui lòng điền đủ thông tin");

    const result = await authService.signUp({
      username,
      email,
      password,
      firstName,
      lastName,
    });

    return res.status(201).json({
      success: true,
      message: "đăng ký tài khoản thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const signInHandler = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password)
      throw new error.BadRequestError("thiếu email hoặc password");

    const result = await authService.signIn({
      email,
      password,
    });

    return res.status(200).json({
      success: true,
      message: "đăng nhập thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

export const signOutHandler = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) throw new error.BadRequestError("thiếu refresh token");

    await authService.signOut({ refreshToken });

    return res.status(200).json({
      success: true,
      message: "đăng xuất thành công",
    });
  } catch (e) {
    next(e);
  }
};

export const refreshTokenHandler = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) throw new error.BadRequestError("thiếu refresh token");

    const result = await authService.refresh({ refreshToken });

    return res.status(200).json({
      success: true,
      message: "refresh token thành công",
      data: result,
    });
  } catch (e) {
    next(e);
  }
};
