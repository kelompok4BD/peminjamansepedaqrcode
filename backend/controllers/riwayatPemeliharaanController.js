const Riwayat = require('../models/riwayatPemeliharaan');

exports.getAllRiwayat = async (req, res) => {
  try {
    const data = await Riwayat.getAll();
    res.json({ success: true, data });
  } catch (err) {
    console.error('❌ Gagal ambil riwayat pemeliharaan:', err);
    res.status(500).json({ 
      success: false, 
      message: 'Gagal ambil riwayat pemeliharaan',
      error: err.message 
    });
  }
};
