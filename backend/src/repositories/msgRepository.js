import Message from '../models/message.js'

// gửi tin nhắn

// gửi riêng


// gửi nhóm

// xóa tin nhắn
export const deleteMessage = (msgId) => Message.findByIdAndDelete(msgId)