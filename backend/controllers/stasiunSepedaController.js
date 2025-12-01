const Stasiun = require("../models/stasiunSepeda");
const logActivity = require('../utils/logActivity');

exports.getAllStasiun = (req, res) => {
  Stasiun.getAll((err, data) => {
    if (err) {
      console.error("❌ Gagal ambil data stasiun:", err);
      return res.status(500).json({ message: "Gagal ambil data stasiun" });
    }
    res.json({ data });
  });
};

exports.getStasiunById = (req, res) => {
  const { id } = req.params;
  Stasiun.getById(id, (err, data) => {
    if (err) {
      console.error('❌ Gagal ambil stasiun:', err);
      return res.status(500).json({ message: 'Gagal ambil stasiun' });
    }
    if (!data) return res.status(404).json({ message: 'Stasiun tidak ditemukan' });
    res.json({ data });
  });
};

exports.createStasiun = (req, res) => {
  const { nama_stasiun, alamat_stasiun, kapasitas_dock, koordinat_gps } = req.body || {};
  if (!nama_stasiun) {
    return res.status(400).json({ message: 'Nama stasiun wajib diisi' });
  }
  Stasiun.create({ nama_stasiun, alamat_stasiun, kapasitas_dock, koordinat_gps }, (err, result) => {
    if (err) {
      console.error('❌ Gagal menambah stasiun:', err);
      return res.status(500).json({ message: 'Gagal menambah stasiun', error: err });
    }
    res.status(201).json({ success: true, data: { id_stasiun: result.insertId, nama_stasiun, alamat_stasiun, kapasitas_dock, koordinat_gps }, message: 'Stasiun berhasil ditambahkan' });
    logActivity(req, 'Create Stasiun', `Menambahkan stasiun id=${result.insertId} nama=${nama_stasiun}`);
  });
};

exports.updateStasiun = (req, res) => {
  const { id } = req.params;
  const { nama_stasiun, alamat_stasiun, kapasitas_dock, koordinat_gps } = req.body || {};
  if (!nama_stasiun) {
    return res.status(400).json({ message: 'Nama stasiun wajib diisi' });
  }
  Stasiun.update(id, { nama_stasiun, alamat_stasiun, kapasitas_dock, koordinat_gps }, (err, result) => {
    if (err) {
      console.error('❌ Gagal update stasiun:', err);
      return res.status(500).json({ message: 'Gagal update stasiun', error: err });
    }
    res.json({ success: true, message: 'Stasiun berhasil diperbarui' });
    logActivity(req, 'Update Stasiun', `Update stasiun id=${id} nama=${nama_stasiun}`);
  });
};

exports.deleteStasiun = (req, res) => {
  const { id } = req.params;
  Stasiun.delete(id, (err) => {
    if (err) {
      console.error('❌ Gagal hapus stasiun:', err);
      return res.status(500).json({ message: 'Gagal hapus stasiun', error: err });
    }
    res.json({ success: true, message: 'Stasiun berhasil dihapus' });
    logActivity(req, 'Delete Stasiun', `Hapus stasiun id=${id}`);
  });
};
