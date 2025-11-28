import Session from '../models/session.js'

export const findSessionById = (id) => Session.findById(id).lean()

export const findSessionByRefreshToken = (refreshToken) => Session.findOne({ refreshToken }).lean()

export const insertSession = (payload) => Session.create(payload)

export const updateSession = (sessionId, payload) => Session.findByIdAndUpdate(sessionId, payload, { new: true }).lean()

export const deleteSession = (sessionId) => Session.findByIdAndDelete(sessionId).lean()