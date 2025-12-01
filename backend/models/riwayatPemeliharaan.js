const db = require('../config/db');

const Riwayat = {
  getAll: (callback) => {
    db.query(
      "SELECT * FROM riwayat_pemeliharaan ORDER BY tanggal_mulai DESC",
      callback
    );
  }
};

module.exports = Riwayat;
