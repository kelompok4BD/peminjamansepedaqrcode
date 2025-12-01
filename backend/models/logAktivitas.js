const { pool: db } = require('../config/db');

const LogAktivitas = {
  getAll: (callback) => {
    db.query("SELECT * FROM log_aktivitas_sistem ORDER BY waktu_aktivitas DESC", callback);
  },

  create: (data, callback) => {
    const waktu = data.waktu_aktivitas || new Date();

    db.query(
      `INSERT INTO log_aktivitas_sistem 
      (id_pegawai, waktu_aktivitas, jenis_aktivitas, deskripsi_aktivitas) 
      VALUES (?, ?, ?, ?)`,
      [
        data.id_pegawai || null,
        waktu,
        data.jenis_aktivitas || null,
        data.deskripsi_aktivitas || "-"
      ],
      callback
    );
  },
};

module.exports = LogAktivitas;
