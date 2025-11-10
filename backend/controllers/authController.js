const User = require('../models/user');

exports.register = async (req, res) => {
  try {
    const { id_NIM_NIP, nama, password } = req.body;
    
    console.log("📝 Data registrasi diterima:", { id_NIM_NIP, nama });

    if (!id_NIM_NIP || !nama || !password) {
      return res.status(400).json({ 
        message: "NIM/NIP, nama, dan password wajib diisi!" 
      });
    }

    User.findById(id_NIM_NIP, (err, results) => {
      if (err) {
        console.error("DB error:", err);
        return res.status(500).json({ 
          message: "Server error" 
        });
      }

      if (results.length > 0) {
        return res.status(400).json({ 
          message: "NIM/NIP sudah terdaftar!" 
        });
      }

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

      User.create(userData, (err, result) => {
        if (err) {
          console.error("DB error:", err);
          return res.status(500).json({ 
            message: "Gagal mendaftar, coba lagi nanti" 
          });
        }

        // Return success with user data
        res.status(201).json({
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
    console.error("Server error:", error);
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
        console.error("Login error:", err);
        return res.status(500).json({ 
          message: "Server error" 
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
        user: user
      });
    });

  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({ 
      message: "Terjadi kesalahan, coba lagi nanti" 
    });
  }
};