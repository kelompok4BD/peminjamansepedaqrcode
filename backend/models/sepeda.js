const db = require("../config/db");

const Sepeda = {
  getAll: (callback) => {
    const sql = "SELECT * FROM sepeda";
    db.query(sql, (err, results) => {
      if (err) return callback(err, null);

      const mappedResults = results.map(s => ({
        id: s.id_sepeda,
        merk: s.merk_model || "Tidak diketahui",
        status: s.status_saat_ini || "Tersedia", 
        tahun: s.tahun_pembelian,
        kondisi: s.status_perawatan,
        kode_qr: s.kode_qr_sepeda,
        id_stasiun: s.id_stasiun
      }));

      callback(null, mappedResults);
    });
  },

  create: (data, callback) => {
    const sql = `
      INSERT INTO sepeda (
        merk_model, 
        tahun_pembelian, 
        status_saat_ini, 
        status_perawatan, 
        kode_qr_sepeda,
        id_stasiun
      ) VALUES (?, ?, ?, ?, ?, ?)
    `;

    db.query(sql, [
      data.merk,
      data.tahun || new Date().getFullYear(),
      data.status || "Tersedia",
      data.kondisi || "Baik",
      data.kode_qr || `QR${Date.now()}`,
      data.id_stasiun || null
    ], callback);
  },

  updateStatus: (id, status, kondisi, callback) => {
    const sql = "UPDATE sepeda SET status_saat_ini = ?, status_perawatan = ? WHERE id_sepeda = ?";
    db.query(sql, [status, kondisi || "Baik", id], callback);
  },

  delete: (id, callback) => {
    const sql = "DELETE FROM sepeda WHERE id_sepeda = ?";
    db.query(sql, [id], callback);
  },

  update: (id, data, callback) => {
    const sql = `
      UPDATE sepeda 
      SET merk_model = ?, 
          tahun_pembelian = ?, 
          status_saat_ini = ?, 
          status_perawatan = ?,
          kode_qr_sepeda = ?,
          id_stasiun = ?
      WHERE id_sepeda = ?
    `;

    db.query(sql, [
      data.merk_model,
      data.tahun_pembelian,
      data.status_saat_ini || "Tersedia",
      data.status_perawatan || "Baik",
      data.kode_qr_sepeda,
      data.id_stasiun || null,
      id
    ], callback);
  }
};

module.exports = Sepeda;
