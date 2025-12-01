const db = require("../config/db");

const Stasiun = {
  getAll: (callback) => {
    const sql = "SELECT * FROM stasiun_sepeda";
    db.query(sql, (err, results) => {
      if (err) return callback(err);
      callback(null, results);
    });
  },

  getById: (id, callback) => {
    const sql = "SELECT * FROM stasiun_sepeda WHERE id_stasiun = ? LIMIT 1";
    db.query(sql, [id], (err, results) => {
      if (err) return callback(err);
      callback(null, results[0] || null);
    });
  },

  create: (data, callback) => {
    const sql = `INSERT INTO stasiun_sepeda (nama_stasiun, alamat_stasiun, kapasitas_dock, koordinat_gps) VALUES (?, ?, ?, ?)`;
    db.query(sql, [data.nama_stasiun, data.alamat_stasiun, data.kapasitas_dock || null, data.koordinat_gps || null], callback);
  },

  update: (id, data, callback) => {
    const sql = `UPDATE stasiun_sepeda SET nama_stasiun = ?, alamat_stasiun = ?, kapasitas_dock = ?, koordinat_gps = ? WHERE id_stasiun = ?`;
    db.query(sql, [data.nama_stasiun, data.alamat_stasiun, data.kapasitas_dock || null, data.koordinat_gps || null, id], callback);
  },

  delete: (id, callback) => {
    const sql = `DELETE FROM stasiun_sepeda WHERE id_stasiun = ?`;
    db.query(sql, [id], callback);
  },
};

module.exports = Stasiun;
