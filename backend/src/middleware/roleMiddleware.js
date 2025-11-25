export const checkRole = (req, res, next) => {
  if (req.existingUser.role !== "admin") {
    return res.status(403).json({
      success: false,
      message: "không đủ quyền truy câp",
    });
  }
  next();
};
