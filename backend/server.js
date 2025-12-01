const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const db = require("./config/db");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Optional: middleware logging admin
try {
  app.use(require("./middleware/extractAdmin"));
} catch (err) {
  console.warn("⚠️ Middleware extractAdmin tidak ditemukan, dilewati.");
}

// Import routes
const sepedaRoutes = require("./routes/sepedaRoutes");
const userRoutes = require("./routes/userRoutes");
const transaksiPeminjamanRoutes = require("./routes/transaksiPeminjamanRoutes");
const authRoutes = require("./routes/authRoutes");
const pengaturanRoutes = require("./routes/pengaturanRoutes");
const stasiunSepedaRoutes = require("./routes/stasiunSepedaRoutes");
const riwayatPemeliharaanRoutes = require("./routes/riwayatPemeliharaanRoutes");
const laporanKerusakanRoutes = require("./routes/laporanKerusakanRoutes");
const pegawaiRoutes = require("./routes/pegawaiRoutes");
const logAktivitasRoutes = require("./routes/logAktivitasRoutes");

// Gunakan routes
app.use("/api/sepeda", sepedaRoutes);
app.use("/api/user", userRoutes);
app.use("/api/transaksi_peminjaman", transaksiPeminjamanRoutes);
app.use("/api/transaksi-peminjaman", transaksiPeminjamanRoutes); // Alias
app.use("/api/auth", authRoutes);
app.use("/api/pengaturan", pengaturanRoutes);
app.use("/api/stasiun_sepeda", stasiunSepedaRoutes);
app.use("/api/riwayat_pemeliharaan", riwayatPemeliharaanRoutes);
app.use("/api/laporan_kerusakan", laporanKerusakanRoutes);
app.use("/api/pegawai", pegawaiRoutes);
app.use("/api/log_aktivitas", logAktivitasRoutes);

// Route tes
app.get("/", (req, res) => {
  res.send("🚴‍♂️ Backend Peminjaman Sepeda Kampus Aktif!");
});

// Pastikan pakai PORT dari Render
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di port ${PORT}`);
});