const { pool: db } = require('../config/db');

const Pegawai = {
  getAll: (callback) => {
    db.query('SELECT * FROM pegawai_admin', callback);
  },

  create: (data, callback) => {
    db.query(
      `INSERT INTO pegawai_admin 
        (nama_pegawai, jabatan, no_hp_pegawai, username)
       VALUES (?, ?, ?, ?)`,
      [
        data.nama_pegawai,
        data.jabatan,
        data.no_hp_pegawai,
        data.username
      ],
      callback
    );
  }
};

module.exports = Pegawai;
