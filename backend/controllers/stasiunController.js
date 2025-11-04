const Stasiun = require('../models/Stasiun');

// ambil semua stasiun sepeda
exports.getAllStasiun = (req, res) => {
  Stasiun.getAll((err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil stasiun:', err);
      return res.status(500).json({ message: 'Gagal ambil stasiun' });
    }

    res.json(rows);
  });
};
