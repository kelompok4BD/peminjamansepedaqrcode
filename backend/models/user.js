const { pool: db } = require("../config/db");

const User = {
  getAll: (callback) => {
    db.query("SELECT * FROM `user`", callback);
  },

  findById: (id, callback) => {
    db.query("SELECT * FROM `user` WHERE id_NIM_NIP = ?", [id], callback);
  },

  findForLogin: (id, callback) => {
    const sql = `
      SELECT 
        id_NIM_NIP, 
        nama, 
        jenis_pengguna, 
        status_akun, 
        email_kampus,
        no_hp_pengguna,
        password 
      FROM \`user\`
      WHERE id_NIM_NIP = ?
    `;
    db.query(sql, [id], callback);
  },

  create: (data, callback) => {
    const sql = `
      INSERT INTO \`user\` (
        id_NIM_NIP, 
        nama, 
        email_kampus, 
        status_jaminan, 
        status_akun, 
        jenis_pengguna, 
        no_hp_pengguna, 
        password
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;
    db.query(
      sql,
      [
        data.id_NIM_NIP,
        data.nama,
        data.email_kampus || null,
        data.status_jaminan || 'tidak',
        data.status_akun || 'aktif',
        data.jenis_pengguna || 'user',
        data.no_hp_pengguna || null,
        data.password,
      ],
      callback
    );
  },

  update: (id, data, callback) => {
    const sql = `
      UPDATE \`user\`
      SET password = ?, status_akun = ?
      WHERE id_NIM_NIP = ?
    `;

    db.query(sql, [
      data.password || null,
      data.status_akun || "aktif",
      id
    ], callback);
  },

  delete: (id, callback) => {
    db.query("DELETE FROM `user` WHERE id_NIM_NIP = ?", [id], callback);
  },
};

module.exports = User;
