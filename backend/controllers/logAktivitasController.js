const LogAktivitas = require('../models/logAktivitas');

exports.getAllLog = (req, res) => {
  LogAktivitas.getAll((err, result) => {
    if (err) {
      console.error("❌ getAllLog error:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal ambil log aktivitas"
      });
    }

    res.json({
      success: true,
      data: result || []
    });
  });
};

exports.createLog = (req, res) => {
  const { jenis_aktivitas } = req.body;

  if (!jenis_aktivitas) {
    return res.status(400).json({
      success: false,
      message: "jenis_aktivitas wajib diisi"
    });
  }

  LogAktivitas.create(req.body, (err) => {
    if (err) {
      console.error("❌ createLog error:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal menambah log aktivitas"
      });
    }

    res.status(201).json({
      success: true,
      message: "Aktivitas berhasil dicatat!"
    });
  });
};
