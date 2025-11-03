// Kolom: id, id_user, id_sepeda, tanggal_pinjam, tanggal_kembali, status

const db = require("../config/db");

const Peminjaman = {
  getAll: (callback) => {
    db.query("SELECT * FROM peminjaman", callback);
  },

  create: (data, callback) => {
    db.query("INSERT INTO peminjaman SET ?", data, callback);
  },

  updateStatus: (id, status, callback) => {
    db.query("UPDATE peminjaman SET status=? WHERE id=?", [status, id], callback);
  },
};

module.exports = Peminjaman;
