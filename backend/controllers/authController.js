const db = require("../config/db");

exports.register = (req, res) => {
  const { id_NIM_NIP, nama, password, role } = req.body;
  
  console.log("📝 Data registrasi diterima:", { id_NIM_NIP, nama, password, role });

  if (!id_NIM_NIP || !nama || !password) {
    console.log("❌ Data tidak lengkap");
    return res.status(400).json({ 
      message: "NIM/NIP, nama, dan password wajib diisi!" 
    });
  }

  // Check if user already exists
  db.query(
    "SELECT id_NIM_NIP FROM user WHERE id_NIM_NIP = ?",
    [id_NIM_NIP],
    (err, results) => {
      if (err) {
        console.error("DB error:", err);
        return res.status(500).json({ message: "Server error" });
      }

      if (results.length > 0) {
        return res.status(400).json({ 
          message: "NIM/NIP sudah terdaftar!" 
        });
      }

      // Insert new user
      const userData = {
        id_NIM_NIP,
        nama,
        password,
        email_kampus: ''
      };

      db.query(
        "INSERT INTO user (id_NIM_NIP, nama, password, email_kampus) VALUES (?, ?, ?, ?)",
        [userData.id_NIM_NIP, userData.nama, userData.password, userData.email_kampus],
        (err, result) => {
        if (err) {
          console.error("DB error:", err);
          return res.status(500).json({ message: "Server error" });
        }

        res.status(201).json({
          message: "Registrasi berhasil!",
          userId: result.insertId
        });
      });
    }
  );
};

exports.login = (req, res) => {
  const { id_NIM_NIP, password } = req.body;

  console.log("🟡 Data diterima dari Flutter:", req.body); // debug log

  if (!id_NIM_NIP || !password) {
    return res.status(400).json({ message: "ID dan Password wajib diisi!" });
  }

  // 🔹 Ubah ke tabel user
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