import mongoose from 'mongoose'

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_CONNECTION_STRING)
        console.log('ket noi csdl thanh cong')
    } catch (e) {
        console.error(`ket noi csdl that bai ${e.message}`)
        process.exit(1)
    }
}

export default connectDB