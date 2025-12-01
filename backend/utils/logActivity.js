const LogAktivitas = require("../models/logAktivitas");

async function logActivity({ id_pegawai, jenis_aktivitas, deskripsi_aktivitas }) {
  try {
    const data = {
      id_pegawai: id_pegawai || null,
      waktu_aktivitas: new Date(),
      jenis_aktivitas,
      deskripsi_aktivitas,
    };

    LogAktivitas.create(data, (err) => {
      if (err) {
        console.error("❌ Gagal menyimpan log aktivitas:", err.message || err);
      } else {
        console.log("✅ Log aktivitas tersimpan:", jenis_aktivitas);
      }
    });
  } catch (error) {
    console.error("❌ Terjadi kesalahan pada logActivity:", error);
  }
}

module.exports = logActivity;
