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

  console.log("📝 createLaporan request body:", JSON.stringify(req.body, null, 2));

  if (!id_sepeda || !id_pegawai || !deskripsi_kerusakan) {
    return res.status(400).json({
      success: false,
      message: "id_sepeda, id_pegawai dan deskripsi_kerusakan wajib diisi"
    });
  }

  LaporanKerusakan.create(req.body, (err, result) => {
    if (err) {
      console.error("❌ createLaporan error:", err?.message || err, "full:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal menambah laporan kerusakan: " + (err?.message || err)
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

  LaporanKerusakan.updateStatus(id, status, (err, result) => {
    if (err) {
      console.error("❌ updateStatus error:", err);
      return res.status(500).json({
        success: false,
        message: "Gagal update status laporan"
      });
    }

    if (result && result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Laporan tidak ditemukan"
      });
    }

    res.json({
      success: true,
      message: "Status laporan berhasil diperbarui"
    });
  });
};
