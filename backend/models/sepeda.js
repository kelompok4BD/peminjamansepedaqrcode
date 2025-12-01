const { promise: db } = require("../config/db");

const Sepeda = {
  // Ambil semua sepeda
  getAll: async () => {
    const sql = "SELECT * FROM sepeda";

    try {
      const [results] = await db.query(sql);

      return results.map((s) => ({
        id: s.id_sepeda,
        merk: s.merk_model || "Tidak diketahui",
        status: s.status_saat_ini || "Tersedia",
        tahun: s.tahun_pembelian,
        kondisi: s.status_perawatan,
        kode_qr: s.kode_qr_sepeda,
        id_stasiun: s.id_stasiun
      }));
    } catch (err) {
      throw err;
    }
  },

  // Tambah data sepeda
  create: async (data) => {
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

    try {
      const [result] = await db.query(sql, [
        data.merk,
        data.tahun || new Date().getFullYear(),
        data.status || "Tersedia",
        data.kondisi || "Baik",
        data.kode_qr || `QR${Date.now()}`,
        data.id_stasiun || null
      ]);

      return result;
    } catch (err) {
      throw err;
    }
  },

  // Update status & kondisi sepeda
  updateStatus: async (id, status, kondisi) => {
    const sql =
      "UPDATE sepeda SET status_saat_ini = ?, status_perawatan = ? WHERE id_sepeda = ?";

    try {
      const [result] = await db.query(sql, [
        status,
        kondisi || "Baik",
        id
      ]);

      return result;
    } catch (err) {
      throw err;
    }
  },

  // Hapus sepeda
  delete: async (id) => {
    const sql = "DELETE FROM sepeda WHERE id_sepeda = ?";

    try {
      const [result] = await db.query(sql, [id]);
      return result;
    } catch (err) {
      throw err;
    }
  },

  // Update data sepeda
  update: async (id, data) => {
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

    try {
      const [result] = await db.query(sql, [
        data.merk_model,
        data.tahun_pembelian,
        data.status_saat_ini || "Tersedia",
        data.status_perawatan || "Baik",
        data.kode_qr_sepeda,
        data.id_stasiun || null,
        id
      ]);

      return result;
    } catch (err) {
      throw err;
    }
  }
};

module.exports = Sepeda;
