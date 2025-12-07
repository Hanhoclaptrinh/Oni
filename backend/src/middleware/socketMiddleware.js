import jwt from "jsonwebtoken";
import User from "../models/user.js";

export default async function socketAuth(socket, next) {
  try {
    // lay token tu client
    const token =
      socket.handshake.auth?.token || socket.handshake.headers?.token;

    if (!token) {
      const err = new Error("NO_TOKEN");
      err.data = { msg: "thiếu token" };
      return next(err);
    }

    // decode token
    const decoded = jwt.verify(token, process.env.PRIVATE_ACCESS_TOKEN);

    // lay user tu db
    const user = await User.findById(decoded.id).select(
      "_id username displayName avatarUrl"
    );
    if (!user) {
      const err = new Error("USER_NOT_FOUND");
      err.data = { msg: "không tìm thấy user" };
      return next(err);
    }

    socket.userId = user._id.toString();
    socket.user = user;

    next();
  } catch (e) {
    console.error("Socket Auth Failed:", err.message);

    const error = new Error("INVALID_TOKEN");
    error.data = { msg: "token không hợp lệ hoặc hết hạn" };
    next(error);
  }
}
