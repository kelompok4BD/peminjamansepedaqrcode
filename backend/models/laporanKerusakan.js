const { pool: db } = require('../config/db');

const LaporanKerusakan = {
  getAll: (callback) => {
    db.query('SELECT * FROM laporan_kerusakan ORDER BY tanggal_laporan DESC', callback);
  },

  create: (data, callback) => {
    const sql = `
      INSERT INTO laporan_kerusakan 
      (id_sepeda, id_pegawai, deskripsi_kerusakan, tanggal_laporan, status_perbaikan)
      VALUES (?, ?, ?, ?, ?)
    `;

    db.query(sql, [
      data.id_sepeda || null,
      data.id_pegawai || null,
      data.deskripsi_kerusakan || null,
      data.tanggal_laporan || new Date(),
      data.status_perbaikan || "proses",
    ], callback);
  },

  updateStatus: (id, status, callback) => {
    db.query(
      "UPDATE laporan_kerusakan SET status_perbaikan = ? WHERE id_laporan = ?",
      [status, id],
      callback
    );
  }
};

module.exports = LaporanKerusakan;
