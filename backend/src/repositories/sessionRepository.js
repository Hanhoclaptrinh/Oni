import Session from '../models/session.js'

export const findSessionByRefreshToken = (refreshToken) => Session.findOne({ refreshToken }).lean()

export const insertSession = (payload) => Session.create(payload)

export const deleteSession = (sessionId) => Session.findByIdAndDelete(sessionId).lean()