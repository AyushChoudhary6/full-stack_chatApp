import pkg from 'pg';
const { Pool } = pkg;

let pool;

export const connectDB = async () => {
  const databaseUrl = process.env.DATABASE_URL;
  if (!databaseUrl) {
    console.log('PostgreSQL connection error: DATABASE_URL environment variable is required');
    process.exit(1);
  }

  const maxAttempts = 10;
  const retryDelayMs = 3000;

  const delay = (ms) => new Promise((res) => setTimeout(res, ms));

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      pool = new Pool({
        connectionString: databaseUrl,
        max: 10,
        idleTimeoutMillis: 30000,
        connectionTimeoutMillis: 5000,
      });

      // Test the connection
      const client = await pool.connect();
      console.log(`PostgreSQL connected: ${client.host || 'localhost'}`);
      client.release();
      
      // Create tables if they don't exist
      await createTables();
      
      return pool;
    } catch (error) {
      console.log(`PostgreSQL connection attempt ${attempt} failed: ${error.message}`);
      if (attempt === maxAttempts) {
        console.log('PostgreSQL connection error: exceeded maximum retries');
        process.exit(1);
      }
      await delay(retryDelayMs);
    }
  }
};

const createTables = async () => {
  const client = await pool.connect();
  try {
    // Create users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        fullname VARCHAR(255) NOT NULL,
        password VARCHAR(255) NOT NULL,
        profile_pic TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Create messages table
    await client.query(`
      CREATE TABLE IF NOT EXISTS messages (
        id SERIAL PRIMARY KEY,
        sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        receiver_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        text TEXT,
        image TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    console.log('Database tables created successfully');
  } catch (error) {
    console.error('Error creating tables:', error);
  } finally {
    client.release();
  }
};

export const getDB = () => {
  if (!pool) {
    throw new Error('Database not initialized. Call connectDB first.');
  }
  return pool;
};
