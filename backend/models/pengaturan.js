const db = require('../config/db');

const Pengaturan = {
  getAll: (callback) => {
    db.query("SELECT * FROM pengaturan_sistem", callback);
  },

  getById: (id, callback) => {
    db.query(
      "SELECT * FROM pengaturan_sistem WHERE id_pengaturan = ?",
      [id],
      callback
    );
  },

  update: (id, data, callback) => {
    db.query(
      "UPDATE pengaturan_sistem SET ? WHERE id_pengaturan = ?",
      [data, id],
      callback
    );
  }
};

module.exports = Pengaturan;
