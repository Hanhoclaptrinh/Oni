import mongoose from 'mongoose'

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_CONNECTION_STRING)
        console.log('connect to db successfully')
    } catch (e) {
        console.error(`failed to connect to db ${e.message}`)
        process.exit(1)
    }
}

export default connectDB