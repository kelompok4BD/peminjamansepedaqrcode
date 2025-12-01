const Pengaturan = require('../models/pengaturan');

exports.getAllPengaturan = (req, res) => {
  Pengaturan.getAll((err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil pengaturan:', err);
      return res.status(500).json({ message: 'Gagal ambil pengaturan' });
    }

    res.json({ success: true, data: rows });
  });
};

exports.getPengaturanById = (req, res) => {
  const { id } = req.params;

  Pengaturan.getById(id, (err, rows) => {
    if (err) {
      console.error('❌ Gagal ambil pengaturan:', err);
      return res.status(500).json({ message: 'Gagal ambil pengaturan' });
    }

    if (!rows || rows.length === 0) {
      return res.status(404).json({ message: 'Pengaturan tidak ditemukan' });
    }

    res.json(rows[0]);
  });
};

exports.updatePengaturan = (req, res) => {
  const { id } = req.params; // AMBIL DARI URL, BUKAN BODY
  const {
    batas_waktu_pinjam,
    tarif_denda_per_jam,
    informasi_kontak_darurat,
    batas_wilayah_gps
  } = req.body;

  const data = {
    batas_waktu_pinjam,
    tarif_denda_per_jam,
    informasi_kontak_darurat,
    batas_wilayah_gps
  };

  Pengaturan.update(id, data, (err, result) => {
    if (err) {
      console.error('❌ Gagal update pengaturan:', err);
      return res.status(500).json({ message: 'Gagal update pengaturan' });
    }

    res.json({ message: 'Pengaturan berhasil diperbarui', id_pengaturan: id });
  });
};
