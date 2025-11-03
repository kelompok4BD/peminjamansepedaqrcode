const Peminjaman = require("../models/Peminjaman");

// ambil semua data peminjaman
exports.getAllPeminjaman = (req, res) => {
  Peminjaman.getAll((err, rows) => {
    if (err) return res.status(500).send(err);
    res.json(rows);
  });
};

// tambah peminjaman baru
exports.createPeminjaman = (req, res) => {
  const data = req.body;
  if (!data.id_user || !data.id_sepeda) {
    return res.status(400).json({ message: "id_user dan id_sepeda wajib diisi!" });
  }

  data.tanggal_pinjam = new Date();
  data.status = "dipinjam";

  Peminjaman.create(data, (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Peminjaman berhasil ditambahkan!" });
  });
};

// update status peminjaman (misal: dikembalikan)
exports.updateStatus = (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  Peminjaman.updateStatus(id, status, (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "Status peminjaman berhasil diupdate!" });
  });
};
