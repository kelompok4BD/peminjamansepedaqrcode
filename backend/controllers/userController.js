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

  // Tambahkan user baru
  User.create(data, (err, result) => {
    if (err) return res.status(500).send(err);
    res.json({ message: "User berhasil ditambahkan!" });
  });
};
