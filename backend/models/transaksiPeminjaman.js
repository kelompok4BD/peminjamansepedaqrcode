const db = require("../config/db").promise;

const TransaksiPeminjaman = {
  getAll: async () => {
    const sql = `
      SELECT 
        t.*,
        u.nama AS nama_peminjam,
        s.merk_model AS merk_sepeda,
        s.kode_qr_sepeda,
        TIMESTAMPDIFF(MINUTE, t.waktu_pinjam, t.waktu_kembali) AS durasi
      FROM transaksi_peminjaman t
      LEFT JOIN \`user\` u ON t.id_user = u.id_NIM_NIP
      LEFT JOIN \`sepeda\` s ON t.id_sepeda = s.id_sepeda
      ORDER BY t.waktu_pinjam DESC
    `;
    const [rows] = await db.query(sql);
    return rows.map((r) => ({
      id_transaksi: r.id_transaksi,
      id_user: r.id_user,
      nama_peminjam: r.nama_peminjam,
      id_sepeda: r.id_sepeda,
      merk_sepeda: r.merk_sepeda,
      kode_qr: r.kode_qr_sepeda,
      waktu_pinjam: r.waktu_pinjam,
      waktu_kembali: r.waktu_kembali,
      durasi: r.durasi,
      status_transaksi: r.status_transaksi,
      metode_jaminan: r.metode_jaminan
    }));
  },

  // NOTE: create is handled by controller with transaction to avoid race conditions.
  // Keberadaan fungsi create di-model tidak diperlukan, tapi bisa ditambahkan jika mau.
};

module.exports = TransaksiPeminjaman;
