import mongoose from "mongoose";

export const connectDB = async () => {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.log('MongoDB connection error: MONGODB_URI environment variable is required');
    process.exit(1);
  }

  const maxAttempts = 10;
  const retryDelayMs = 3000;

  const delay = (ms) => new Promise((res) => setTimeout(res, ms));

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const conn = await mongoose.connect(uri, {
        // Additional options for better connection handling
        maxPoolSize: 10,
        serverSelectionTimeoutMS: 5000,
        socketTimeoutMS: 45000,
      });

      console.log(`MongoDB connected: ${conn.connection.host}`);
      return conn;
    } catch (error) {
      console.log(`MongoDB connection attempt ${attempt} failed: ${error.message}`);
      if (attempt === maxAttempts) {
        console.log('MongoDB connection error: exceeded maximum retries');
        process.exit(1);
      }
      await delay(retryDelayMs);
    }
  }
};
