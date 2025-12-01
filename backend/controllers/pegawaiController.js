const Pegawai = require('../models/pegawai');
const logActivity = require('../utils/logActivity');

exports.getAllPegawai = (req, res) => {
  Pegawai.getAll((err, rows) => {
    if (err) {
      console.error("❌ Error getAllPegawai:", err);
      return res.status(500).json({ success: false, message: "Gagal mengambil data pegawai" });
    }

    res.json({ success: true, data: rows || [] });
  });
};

exports.createPegawai = (req, res) => {
  const { nama_pegawai, jabatan, no_hp_pegawai, username } = req.body;

  if (!nama_pegawai) {
    return res.status(400).json({ success: false, message: "Nama wajib diisi" });
  }

  const data = {
    nama_pegawai,
    jabatan: jabatan || null,
    no_hp_pegawai: no_hp_pegawai || null,
    username: username || null
  };

  Pegawai.create(data, (err, result) => {
    if (err) {
      console.error("❌ Error createPegawai:", err);
      return res.status(500).json({ success: false, message: "Gagal menambah pegawai" });
    }

    res.status(201).json({
      success: true,
      message: "Pegawai berhasil ditambahkan!",
      id: result.insertId
    });

    // panggil logActivity TAPI aman
    try {
      logActivity(req, "Create Pegawai", `Menambahkan pegawai nama=${nama_pegawai}`);
    } catch (e) {
      console.error("⚠️ logActivity error:", e);
    }
  });
};
