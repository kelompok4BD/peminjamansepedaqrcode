const Pegawai = require('../models/Pegawai');
const logActivity = require('../utils/logActivity');

exports.getAllPegawai = (req, res) => {
  Pegawai.getAll((err, result) => {
    if (err) return res.status(500).json({ success: false, message: err });
    res.json({ success: true, data: result });
  });
};

exports.createPegawai = (req, res) => {
  const data = req.body;
  if (!data.nama_pegawai)
    return res.status(400).json({ success: false, message: 'Nama wajib diisi' });

  Pegawai.create(data, (err) => {
    if (err) return res.status(500).json({ success: false, message: 'Gagal menambah pegawai' });
    res.status(201).json({ success: true, message: 'Pegawai berhasil ditambahkan!' });
    logActivity(req, 'Create Pegawai', `Menambahkan pegawai nama=${data.nama_pegawai || data.nama}`);
  });
};
