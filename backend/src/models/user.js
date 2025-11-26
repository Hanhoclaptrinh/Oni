import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      minlength: 6,
      maxlength: 20,
      match: [/^[a-z0-9_-]+$/, "username không hợp lệ"],
    },

    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      maxlength: 100,
      match: [
        /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
        "email không hợp lệ",
      ],
    },

    hashedPassword: {
      type: String,
      required: true,
      select: false,
    },

    displayName: {
      type: String,
      required: true,
      trim: true,
      minlength: 3,
      maxlength: 30,
    },

    role: {
      type: String,
      enum: ["user", "admin"],
      default: "user",
    },

    avatarUrl: { type: String, default: null },
    avatarId: { type: String, default: null },

    bio: {
      type: String,
      maxlength: 1000,
      default: "",
    },

    emailVerified: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// response json -> hide password
userSchema.methods.toJSON = function () {
  const obj = this.toObject();
  delete obj.hashedPassword;
  return obj;
};

const user = mongoose.model("User", userSchema);

export default user;
