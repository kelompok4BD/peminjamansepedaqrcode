const Pengaturan = require('../models/Pengaturan');

exports.getAllPengaturan = (req, res) => {
  Pengaturan.getAll((err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil pengaturan:', err);
      return res.status(500).json({ message: 'Gagal ambil pengaturan' });
    }

    res.json(rows);
  });
};
