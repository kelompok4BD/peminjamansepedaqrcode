const db = require("../config/db");

const TransaksiPeminjaman = {
  getAll: (callback) => {
    const sql = `
      SELECT 
        t.*,
        u.nama AS nama_peminjam,
        s.merk_model AS merk_sepeda,
        s.kode_qr_sepeda
      FROM transaksi_peminjaman t
      LEFT JOIN user u ON t.id_user = u.id_NIM_NIP
      LEFT JOIN sepeda s ON t.id_sepeda = s.id_sepeda
      ORDER BY t.waktu_pinjam DESC
    `;

    db.query(sql, (err, results) => {
      if (err) return callback(err);

      const mappedResults = results.map((r) => ({
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

      callback(null, mappedResults);
    });
  },

create: (data, callback) => {
  const sql = `
    INSERT INTO transaksi_peminjaman (
      id_user, 
      id_sepeda, 
      waktu_pinjam,
      status_transaksi,
      metode_jaminan
    ) VALUES (?, ?, NOW(), ?, ?)
  `;

  db.query(
    sql,
    [data.id_user, data.id_sepeda, 'Dipinjam', data.metode_jaminan || 'KTM'],
    (err, result) => {
      if (err) return callback(err);

      if (result.insertId) {
        const updateSepeda = `
          UPDATE sepeda SET status_saat_ini = 'Dipinjam'
          WHERE id_sepeda = ?
        `;
        db.query(updateSepeda, [data.id_sepeda], (updateErr) => {
          if (updateErr) return callback(updateErr);
          callback(null, result);
        });
      } else {
        callback(null, result);
      }
    }
  );
},


  updateStatus: (id, status, callback) => {
    const now = new Date();
    // Normalize status casing
    const normalizedStatus = status.charAt(0).toUpperCase() + status.slice(1).toLowerCase();
    const sql =
      normalizedStatus === "Dikembalikan"
        ? "UPDATE transaksi_peminjaman SET status_transaksi = ?, waktu_kembali = ? WHERE id_transaksi = ?"
        : "UPDATE transaksi_peminjaman SET status_transaksi = ? WHERE id_transaksi = ?";

    const params =
      normalizedStatus === "Dikembalikan" ? [normalizedStatus, now, id] : [normalizedStatus, id];

    db.query(sql, params, (err, result) => {
      if (err) return callback(err);

      if (normalizedStatus === "Dikembalikan") {
        const getSepedaId =
          "SELECT id_sepeda FROM transaksi_peminjaman WHERE id_transaksi = ?";
        db.query(getSepedaId, [id], (getErr, rows) => {
          if (getErr) return callback(getErr);
          if (rows.length > 0) {
            const updateSepeda =
              "UPDATE sepeda SET status_saat_ini = 'Tersedia' WHERE id_sepeda = ?";
            db.query(updateSepeda, [rows[0].id_sepeda], (updateErr) => {
              if (updateErr) return callback(updateErr);
              callback(null, result);
            });
          } else {
            callback(null, result);
          }
        });
      } else {
        callback(null, result);
      }
    });
  },
};

module.exports = TransaksiPeminjaman;
