import dotenv from 'dotenv'
dotenv.config({ path: '../.env' })

import mongoose from 'mongoose'
import User from './models/user.js'
import bcrypt from 'bcrypt'

const seed = async () => {
    await mongoose.connect(process.env.MONGODB_CONNECTION_STRING)

    const exist = await User.findOne({ email: "admin@gmail.com" })
    if (exist) {
        console.log("Admin da ton tai")
        process.exit(0)
    }

    const hashedPassword = await bcrypt.hash(process.env.ADMIN_SEED_PASS, 12)

    await User.create({
        username: "superadmin",
        email: "systemadmin@gmail.com",
        hashedPassword,
        displayName: "System Admin",
        role: "admin"
    })

    console.log("tạo admin thành công")
    process.exit(0)
}

seed()
