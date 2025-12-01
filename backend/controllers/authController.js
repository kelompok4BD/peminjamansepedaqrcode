const User = require('../models/user');

exports.register = async (req, res) => {
  try {
    let { id_NIM_NIP, nama, password } = req.body || {};

    // Normalize inputs
    if (id_NIM_NIP !== undefined && id_NIM_NIP !== null) {
      id_NIM_NIP = String(id_NIM_NIP).trim();
    }
    nama = nama ? String(nama).trim() : nama;
    password = password ? String(password) : password;

    console.log("📝 Data registrasi diterima:", { id_NIM_NIP, nama, password_length: password?.length || 0 });

    if (!id_NIM_NIP || !nama || !password) {
      console.warn("⚠️ Validasi gagal: ada field kosong");
      return res.status(400).json({
        success: false,
        message: "NIM/NIP, nama, dan password wajib diisi!"
      });
    }

    // Cek apakah sudah terdaftar
    User.findById(id_NIM_NIP, (err, results) => {
      if (err) {
        console.error("❌ Register query error:", err);
        return res.status(500).json({
          message: "Server error: " + err.message
        });
      }

      console.log("✅ Query hasil:", results?.length || 0, "records found");

      if (results && results.length > 0) {
        console.warn("⚠️ NIM/NIP sudah terdaftar", id_NIM_NIP);
        return res.status(409).json({
          success: false,
          message: "NIM/NIP sudah terdaftar!"
        });
      }

      // Data default
      const userData = {
        id_NIM_NIP,
        nama,
        password,
        email_kampus: null,
        status_jaminan: 'tidak',
        status_akun: 'aktif',
        jenis_pengguna: 'user',
        no_hp_pengguna: null
      };

      // Simpan ke DB
      User.create(userData, (err, result) => {
        if (err) {
          console.error("❌ DB create error:", err);
          // handle duplicate entry gracefully
          if (err.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({ success: false, message: 'NIM/NIP sudah terdaftar (duplicate)'});
          }
          return res.status(500).json({
            success: false,
            message: "Gagal mendaftar, coba lagi nanti"
          });
        }

        console.log("✅ User berhasil dibuat dengan ID:", result.insertId);
        res.status(201).json({
          success: true,
          message: "Registrasi berhasil",
          user: {
            id_NIM_NIP: userData.id_NIM_NIP,
            nama: userData.nama,
            jenis_pengguna: userData.jenis_pengguna,
            status_akun: userData.status_akun
          }
        });
      });
    });

  } catch (error) {
    console.error("❌ Server error:", error);
    res.status(500).json({
      message: "Terjadi kesalahan, coba lagi nanti"
    });
  }
};


exports.login = async (req, res) => {
  try {
    const { id_NIM_NIP, password } = req.body;

    console.log("🔑 Login request:", { id_NIM_NIP });

    if (!id_NIM_NIP || !password) {
      return res.status(400).json({
        message: "NIM/NIP dan password wajib diisi!"
      });
    }

    User.findForLogin(id_NIM_NIP, (err, results) => {
      if (err) {
        console.error("❌ Login query error:", err);
        return res.status(500).json({
          message: "Server error: " + err.message
        });
      }

      if (results.length === 0) {
        return res.status(401).json({
          message: "NIM/NIP atau password salah"
        });
      }

      const user = results[0];

      if (password !== user.password) {
        return res.status(401).json({
          message: "NIM/NIP atau password salah"
        });
      }

      if (user.status_akun !== 'aktif') {
        return res.status(403).json({
          message: "Akun tidak aktif. Hubungi admin."
        });
      }

      delete user.password;

      res.json({
        message: "Login berhasil",
        user
      });
    });

  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({
      message: "Terjadi kesalahan, coba lagi nanti"
    });
  }
};
