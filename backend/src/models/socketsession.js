import mongoose from "mongoose";

const socketSessionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    socketId: {
      type: String,
      required: true,
    },

    isOnline: {
      type: Boolean,
      required: true,
    },

    lastActive: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

socketSessionSchema.index({ userId: 1 });
socketSessionSchema.index({ socketId: 1 });

export default mongoose.model("SocketSession", socketSessionSchema);
