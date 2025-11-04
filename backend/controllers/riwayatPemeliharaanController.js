const Riwayat = require('../models/RiwayatPemeliharaan');

// ambil semua riwayat pemeliharaan
exports.getAllRiwayat = (req, res) => {
  Riwayat.getAll((err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil riwayat pemeliharaan:', err);
      return res.status(500).json({ message: 'Gagal ambil riwayat pemeliharaan' });
    }

    res.json(rows);
  });
};
