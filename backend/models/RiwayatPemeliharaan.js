const db = require('../config/db');

const RiwayatPemeliharaan = {
  getAll: (callback) => {
    db.query('SELECT * FROM riwayat_pemeliharaan', callback);
  },
};

module.exports = RiwayatPemeliharaan;
