import mongoose from "mongoose";

const messageSchema = new mongoose.Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
    },

    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    type: {
      type: String,
      enum: ["text", "audio", "video", "file"],
      default: "text",
    },

    content: {
      type: String,
      trim: true,
      default: null,
      maxlength: 5000,
    },

    fileUrl: {
      type: String,
      trim: true,
      default: null,
    },

    seenBy: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],

    // danh dau trang thai tin nhan
    // tin nhan normal hoac tin nhan da cuoc thu hoi
    status: {
      type: String,
      enum: ["normal", "revoked"],
      default: "normal",
      index: true,
    },

    revokedAt: {
      type: Date,
      default: null,
    },

    // xoa 1 phia
    // user nao duoc danh dau thi khong render UI
    hiddenFor: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
      },
    ],

    // thoi gian chinh sua tin nhan
    editedAt: {
      type: Date,
      default: null,
    },

    // tra loi tin nhan
    replyTo: {
      type: {
        messageId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "Message",
        },
        senderId: {
          type: mongoose.Schema.Types.ObjectId,
          ref: "User",
        },
        type: {
          type: String,
          enum: ["text", "audio", "video", "file"],
        },
        content: {
          type: String,
          trim: true,
          maxlength: 5000,
        },
        fileUrl: {
          type: String,
          trim: true,
          default: null,
        },
      },
      default: null,
    },
  },
  { timestamps: true }
);

messageSchema.index({ conversationId: 1, createdAt: -1 });
messageSchema.index({ conversationId: 1, _id: -1 });

export default mongoose.model("Message", messageSchema);
