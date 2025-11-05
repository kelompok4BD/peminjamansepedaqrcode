const User = require("../models/user");

// 🔹 Ambil semua user
exports.getAllUser = (req, res) => {
  User.getAll((err, rows) => {
    if (err) return res.status(500).send(err);
    res.json(rows);
  });
};

// 🔹 Tambah user baru
exports.createUser = (req, res) => {
  const data = req.body;

  // Validasi input
  if (!data.id_NIM_NIP || !data.nama || !data.password) {
    return res
      .status(400)
      .json({ message: "id_NIM_NIP, nama, dan password wajib diisi!" });
  }

  // cek apakah id sudah ada
  User.findById(data.id_NIM_NIP, (err, rows) => {
    if (err) return res.status(500).send(err);
    if (rows && rows.length > 0) {
      return res.status(409).json({ message: "ID sudah terdaftar" });
    }

    // Tambahkan user baru
    User.create(data, (err2, result) => {
      if (err2) return res.status(500).send(err2);
      res.status(201).json({ message: "User berhasil ditambahkan!" });
    });
  });
};