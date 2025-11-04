const db = require('../config/db');

const Pengaturan = {
  getAll: (callback) => {
    db.query('SELECT * FROM pengaturan_sistem', callback);
  },
};

module.exports = Pengaturan;
