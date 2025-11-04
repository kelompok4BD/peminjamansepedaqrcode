const Pengaturan = require('../models/Pengaturan');

// ambil semua pengaturan sistem
exports.getAllPengaturan = (req, res) => {
  Pengaturan.getAll((err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil pengaturan:', err);
      return res.status(500).json({ message: 'Gagal ambil pengaturan' });
    }

    res.json(rows);
  });
};
