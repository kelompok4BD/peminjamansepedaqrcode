const Pengaturan = require('../models/pengaturan');

exports.getAllPengaturan = (req, res) => {
  Pengaturan.getAll((err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil pengaturan:', err);
      return res.status(500).json({ message: 'Gagal ambil pengaturan' });
    }

    res.json(rows);
  });
};

exports.updatePengaturan = (req, res) => {
  const { id_pengaturan, batas_waktu_pinjam, tarif_denda_per_jam, informasi_kontak_darurat, batas_wilayah_gps } = req.body;

  if (!id_pengaturan) {
    return res.status(400).json({ message: 'ID pengaturan diperlukan' });
  }

  const data = {
    batas_waktu_pinjam,
    tarif_denda_per_jam,
    informasi_kontak_darurat,
    batas_wilayah_gps
  };

  Pengaturan.update(id_pengaturan, data, (err, result) => {
    if (err) {
      console.error('❌ Gagal update pengaturan:', err);
      return res.status(500).json({ message: 'Gagal update pengaturan' });
    }

    res.json({ message: 'Pengaturan berhasil diperbarui', id_pengaturan });
  });
};

exports.getPengaturanById = (req, res) => {
  const { id } = req.params;

  Pengaturan.getById(id, (err, row) => {
    if (err) {
      console.error('❌ Gagal ambil pengaturan:', err);
      return res.status(500).json({ message: 'Gagal ambil pengaturan' });
    }

    if (!row) {
      return res.status(404).json({ message: 'Pengaturan tidak ditemukan' });
    }

    res.json(row);
  });
};
