import { getDB } from "../lib/db.js";

class User {
  static async create({ email, fullName, password, profilePic = "" }) {
    const db = getDB();
    const query = `
      INSERT INTO users (email, fullname, password, profile_pic)
      VALUES ($1, $2, $3, $4)
      RETURNING id, email, fullname, profile_pic, created_at, updated_at
    `;
    const values = [email, fullName, password, profilePic];
    const result = await db.query(query, values);
    return result.rows[0];
  }

  static async findByEmail(email) {
    const db = getDB();
    const query = `SELECT * FROM users WHERE email = $1`;
    const result = await db.query(query, [email]);
    return result.rows[0];
  }

  static async findById(id) {
    const db = getDB();
    const query = `SELECT id, email, fullname, profile_pic, created_at, updated_at FROM users WHERE id = $1`;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }

  static async findByIdWithPassword(id) {
    const db = getDB();
    const query = `SELECT * FROM users WHERE id = $1`;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }

  static async updateProfilePic(id, profilePic) {
    const db = getDB();
    const query = `
      UPDATE users SET profile_pic = $1, updated_at = CURRENT_TIMESTAMP
      WHERE id = $2
      RETURNING id, email, fullname, profile_pic, created_at, updated_at
    `;
    const result = await db.query(query, [profilePic, id]);
    return result.rows[0];
  }

  static async findAllExceptUser(userId) {
    const db = getDB();
    const query = `
      SELECT id, email, fullname, profile_pic, created_at, updated_at 
      FROM users WHERE id != $1
    `;
    const result = await db.query(query, [userId]);
    return result.rows;
  }
}

export default User;
