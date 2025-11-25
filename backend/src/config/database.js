import mongoose from 'mongoose'

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_CONNECTION_STRING)
        console.log('kết nối db thành công')
    } catch (e) {
        console.error(`kết nối db thất bại ${e.message}`)
        process.exit(1)
    }
}

export default connectDB