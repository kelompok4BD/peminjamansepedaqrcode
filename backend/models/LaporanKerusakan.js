const db = require('../config/db');

const LaporanKerusakan = {
  getAll: (callback) => {
    db.query('SELECT * FROM laporan_kerusakan', callback);
  },

  create: (data, callback) => {
    const sql = `
      INSERT INTO laporan_kerusakan (id_sepeda, id_pegawai, deskripsi_kerusakan, tanggal_laporan, status_perbaikan)
      VALUES (?, ?, ?, ?, ?)
    `;
    db.query(sql, [
      data.id_sepeda,
      data.id_pegawai,
      data.deskripsi_kerusakan,
      data.tanggal_laporan,
      data.status_perbaikan,
    ], callback);
  },

  updateStatus: (id, status, callback) => {
    db.query(
      'UPDATE laporan_kerusakan SET status_perbaikan = ? WHERE id_laporan = ?',
      [status, id],
      callback
    );
  }
};

module.exports = LaporanKerusakan;
