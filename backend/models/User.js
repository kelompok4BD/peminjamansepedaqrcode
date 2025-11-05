const db = require("../config/db");

const User = {
  // Ambil semua user
  getAll: (callback) => {
    db.query("SELECT * FROM user", callback);
  },

  // Tambah user baru
  create: (data, callback) => {
    const sql =
      "INSERT INTO user (id_NIM_NIP, nama, email_kampus, password) VALUES (?, ?, ?, ?)";
    db.query(
      sql,
      [data.id_NIM_NIP, data.nama, data.email_kampus || "", data.password],
      callback
    );
  },

  // Cari user berdasarkan id_NIM_NIP
  findById: (id, callback) => {
    db.query('SELECT * FROM user WHERE id_NIM_NIP = ?', [id], callback);
  },
};

module.exports = User;
