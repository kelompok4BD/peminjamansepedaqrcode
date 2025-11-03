const db = require("../config/db");

exports.login = (req, res) => {
  const { id_NIM_NIP, password } = req.body;

  console.log("🟡 Data diterima dari Flutter:", req.body); // debug log

  if (!id_NIM_NIP || !password) {
    return res.status(400).json({ message: "ID dan Password wajib diisi!" });
  }

  // 🔹 Ubah ke tabel `user`
  const sql = "SELECT * FROM user WHERE id_NIM_NIP = ? AND password = ?";
  db.query(sql, [id_NIM_NIP, password], (err, results) => {
    if (err) {
      console.error("DB error:", err);
      return res.status(500).json({ message: "Server error" });
    }

    console.log("🔹 Hasil query:", results);

    if (results.length === 0) {
      return res.status(401).json({ message: "ID atau Password salah!" });
    }

    res.json({
      message: "Login berhasil!",
      data: results[0],
    });
  });
};
