const db = require('../config/db');

const LogAktivitas = {
  getAll: (callback) => {
    db.query('SELECT * FROM log_aktivitas_sistem', callback);
  },

  create: (data, callback) => {
    db.query(
      'INSERT INTO log_aktivitas_sistem (id_pegawai, waktu_aktivitas, jenis_aktivitas, deskripsi_aktivitas) VALUES (?, ?, ?, ?)',
      [data.id_pegawai, data.waktu_aktivitas, data.jenis_aktivitas, data.deskripsi_aktivitas],
      callback
    );
  },
};

module.exports = LogAktivitas;
