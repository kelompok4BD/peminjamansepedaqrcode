const LaporanKerusakan = require('../models/laporanKerusakan');

exports.getAllLaporan = (req, res) => {
  LaporanKerusakan.getAll((err, result) => {
    if (err) return res.status(500).json({ success: false, message: err });
    res.json({ success: true, data: result });
  });
};

exports.createLaporan = (req, res) => {
  const data = req.body;
  if (!data.deskripsi_kerusakan)
    return res.status(400).json({ success: false, message: 'Deskripsi wajib diisi' });

  LaporanKerusakan.create(data, (err) => {
    if (err) return res.status(500).json({ success: false, message: 'Gagal menambah laporan' });
    res.status(201).json({ success: true, message: 'Laporan berhasil ditambahkan!' });
  });
};

exports.updateStatus = (req, res) => {
  const id = req.params.id;
  const { status } = req.body;

  LaporanKerusakan.updateStatus(id, status, (err) => {
    if (err) return res.status(500).json({ success: false, message: 'Gagal update status' });
    res.json({ success: true, message: 'Status perbaikan diperbarui' });
  });
};
