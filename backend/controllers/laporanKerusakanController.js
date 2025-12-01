const LaporanKerusakan = require('../models/laporanKerusakan');

exports.getAllLaporan = (req, res) => {
  LaporanKerusakan.getAll((err, rows) => {
    if (err) {
      console.error("❌ getAllLaporan error:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal ambil laporan kerusakan"
      });
    }

    res.json({ success: true, data: rows || [] });
  });
};

exports.createLaporan = (req, res) => {
  const { id_sepeda, id_pegawai, deskripsi_kerusakan } = req.body;

  if (!id_sepeda || !id_pegawai || !deskripsi_kerusakan) {
    return res.status(400).json({
      success: false,
      message: "id_sepeda, id_pegawai dan deskripsi_kerusakan wajib diisi"
    });
  }

  LaporanKerusakan.create(req.body, (err, result) => {
    if (err) {
      console.error("❌ createLaporan error:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal menambah laporan kerusakan"
      });
    }

    res.status(201).json({
      success: true,
      message: "Laporan kerusakan berhasil dibuat",
      id: result.insertId
    });
  });
};

exports.updateStatus = (req, res) => {
  const id = req.params.id;
  const status = req.body.status_perbaikan;

  if (!status) {
    return res.status(400).json({
      success: false,
      message: "status_perbaikan wajib dikirim"
    });
  }

  LaporanKerusakan.updateStatus(id, status, (err) => {
    if (err) {
      console.error("❌ updateStatus error:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal update status laporan"
      });
    }

    res.json({
      success: true,
      message: "Status laporan berhasil diperbarui"
    });
  });
};
