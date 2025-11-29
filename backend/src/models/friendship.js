import mongoose from "mongoose";

const friendShipSchema = new mongoose.Schema(
  {
    requester: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    recipient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },

    status: {
      type: String,
      enum: ["pending", "accepted", "blocked"],
      default: "pending",
      index: true,
    },

    blockedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    actionUser: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
  },
  { timestamps: true }
);

friendShipSchema.index({ requester: 1, recipient: 1 }, { unique: true });

friendShipSchema.index({ requester: 1, status: 1 });
friendShipSchema.index({ recipient: 1, status: 1 });

export default mongoose.model("FriendShip", friendShipSchema);
