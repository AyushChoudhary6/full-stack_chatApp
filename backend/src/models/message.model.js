import { getDB } from "../lib/db.js";

class Message {
  static async create({ senderId, receiverId, text, image }) {
    const db = getDB();
    const query = `
      INSERT INTO messages (sender_id, receiver_id, text, image)
      VALUES ($1, $2, $3, $4)
      RETURNING id, sender_id, receiver_id, text, image, created_at, updated_at
    `;
    const values = [senderId, receiverId, text, image];
    const result = await db.query(query, values);
    return result.rows[0];
  }

  static async findBetweenUsers(userId1, userId2) {
    const db = getDB();
    const query = `
      SELECT m.*, 
             u1.fullname as sender_name, u1.profile_pic as sender_pic,
             u2.fullname as receiver_name, u2.profile_pic as receiver_pic
      FROM messages m
      JOIN users u1 ON m.sender_id = u1.id
      JOIN users u2 ON m.receiver_id = u2.id
      WHERE (m.sender_id = $1 AND m.receiver_id = $2) 
         OR (m.sender_id = $2 AND m.receiver_id = $1)
      ORDER BY m.created_at ASC
    `;
    const result = await db.query(query, [userId1, userId2]);
    return result.rows;
  }

  static async findById(id) {
    const db = getDB();
    const query = `
      SELECT m.*, 
             u1.fullname as sender_name, u1.profile_pic as sender_pic,
             u2.fullname as receiver_name, u2.profile_pic as receiver_pic
      FROM messages m
      JOIN users u1 ON m.sender_id = u1.id
      JOIN users u2 ON m.receiver_id = u2.id
      WHERE m.id = $1
    `;
    const result = await db.query(query, [id]);
    return result.rows[0];
  }
}

export default Message;
