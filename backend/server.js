const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const db = require("./config/db");

const app = express();
app.use(cors());
// Increase JSON body size slightly and preserve raw body for debugging
app.use(bodyParser.json({ limit: '2mb' }));

// Simple request logger to help diagnose admin CRUD failures on Render
app.use((req, res, next) => {
  try {
    const safeBody = req.body && Object.keys(req.body).length ? JSON.stringify(req.body) : null;
    console.log(`➡️ ${req.method} ${req.path} body=${safeBody}`);
  } catch (e) {
    console.log(`➡️ ${req.method} ${req.path} body=<unserializable>`);
  }
  next();
});

// Optional: middleware logging admin
try {
  app.use(require("./middleware/extractAdmin"));
} catch (err) {
  console.warn("⚠️ Middleware extractAdmin tidak ditemukan, dilewati.");
}

// Response wrapper: ensure consistent JSON shape (adds `success` when missing)
app.use((req, res, next) => {
  const oldJson = res.json;
  res.json = function (body) {
    try {
      if (typeof body === 'object' && body !== null) {
        if (res.statusCode >= 400) {
          if (body.success === undefined) body.success = false;
        } else {
          if (body.success === undefined) body.success = true;
        }
      }
    } catch (e) {
      // ignore
    }
    try { console.log(`⬅️ ${req.method} ${req.path} status=${res.statusCode} response=${JSON.stringify(body)}`); } catch(e){}
    return oldJson.call(this, body);
  };
  next();
});

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
app.use("/api/stasiun-sepeda", stasiunSepedaRoutes); // Alias (dash)
app.use("/api/riwayat_pemeliharaan", riwayatPemeliharaanRoutes);
app.use("/api/riwayat-pemeliharaan", riwayatPemeliharaanRoutes); // Alias (dash)
app.use("/api/laporan_kerusakan", laporanKerusakanRoutes);
app.use("/api/laporan-kerusakan", laporanKerusakanRoutes); // Alias (dash)
app.use("/api/pegawai", pegawaiRoutes);
app.use("/api/log_aktivitas", logAktivitasRoutes);
app.use("/api/log-aktivitas", logAktivitasRoutes); // Alias (dash)

// Route tes
app.get("/", (req, res) => {
  res.send("🚴‍♂️ Backend Peminjaman Sepeda Kampus Aktif!");
});

// 404 handler
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: 'Endpoint tidak ditemukan' });
});

// Global error handler (ensure we log full stack traces)
app.use((err, req, res, next) => {
  console.error('🔥 Unhandled error on', req.method, req.path, err.stack || err);
  res.status(500).json({ success: false, message: 'Internal server error', error: err.message || err });
});

// Pastikan pakai PORT dari Render
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di port ${PORT}`);
});