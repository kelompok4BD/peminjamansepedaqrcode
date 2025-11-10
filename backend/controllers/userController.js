const User = require("../models/user");

exports.getAllUser = (req, res) => {
  User.getAll((err, rows) => {
    if (err) return res.status(500).json({ message: "Gagal mengambil user", error: err });
    res.json({ success: true, data: rows });
  });
};

exports.updateUser = (req, res) => {
  const { id_NIM_NIP } = req.params;
  const data = req.body;

  if (!id_NIM_NIP) return res.status(400).json({ message: "ID user wajib disertakan" });

  console.log("🟢 Update data diterima:", data);

  User.update(id_NIM_NIP, data, (err, result) => {
    if (err) {
      console.error("❌ Gagal update:", err);
      return res.status(500).json({ message: "Gagal update user", error: err });
    }
    res.json({ success: true, message: "User berhasil diperbarui!" });
  });
};

exports.deleteUser = (req, res) => {
  const { id_NIM_NIP } = req.params;

  User.delete(id_NIM_NIP, (err, result) => {
    if (err) return res.status(500).json({ message: "Gagal hapus user", error: err });
    res.json({ success: true, message: "User berhasil dihapus!" });
  });
};
