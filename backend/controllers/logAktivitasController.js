const LogAktivitas = require('../models/logAktivitas');

exports.getAllLog = (req, res) => {
  LogAktivitas.getAll((err, result) => {
    if (err) return res.status(500).json({ success: false, message: err });
    res.json({ success: true, data: result });
  });
};

exports.createLog = (req, res) => {
  const data = req.body;
  if (!data.jenis_aktivitas)
    return res.status(400).json({ success: false, message: 'Jenis aktivitas wajib diisi' });

  LogAktivitas.create(data, (err) => {
    if (err) return res.status(500).json({ success: false, message: 'Gagal menambah log' });
    res.status(201).json({ success: true, message: 'Aktivitas dicatat!' });
  });
};
