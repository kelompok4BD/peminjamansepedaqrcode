const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const db = require("./config/db");

const app = express();
app.use(cors());
app.use(bodyParser.json());
// extract admin id and client info for logging
app.use(require('./middleware/extractAdmin'));

// Import routes
const sepedaRoutes = require("./routes/sepedaRoutes");
const userRoutes = require("./routes/userRoutes");
const transaksiPeminjamanRoutes = require("./routes/transaksiPeminjamanRoutes")
const authRoutes = require("./routes/authRoutes"); 
const pengaturanRoutes = require("./routes/pengaturanRoutes");
const stasiunSepedaRoutes = require("./routes/stasiunSepedaRoutes");
const riwayatPemeliharaanRoutes = require("./routes/riwayatPemeliharaanRoutes");
const laporanKerusakanRoutes = require('./routes/laporanKerusakanRoutes');
const pegawaiRoutes = require('./routes/pegawaiRoutes');
const logAktivitasRoutes = require('./routes/logAktivitasRoutes');

// Gunakan routes
app.use("/api/sepeda", sepedaRoutes);
app.use("/api/user", userRoutes);
app.use("/api/transaksi_peminjaman", transaksiPeminjamanRoutes);
app.use("/api/transaksi-peminjaman", transaksiPeminjamanRoutes); // Alias dengan hyphen
app.use("/api", authRoutes); 
app.use("/api/pengaturan", pengaturanRoutes);
app.use("/api/stasiun_sepeda", stasiunSepedaRoutes);
app.use("/api/riwayat_pemeliharaan", riwayatPemeliharaanRoutes);
app.use('/api', laporanKerusakanRoutes);
app.use('/api', pegawaiRoutes);
app.use('/api', logAktivitasRoutes);

// Cek koneksi database
db.connect((err) => {
  if (err) {
    console.error("❌ Gagal konek ke MySQL:", err);
  } else {
    console.log("✅ Terhubung ke MySQL Database peminjaman_sepeda");
  }
});

app.get("/", (req, res) => {
  res.send("🚴‍♂️ Backend Peminjaman Sepeda Kampus Aktif!");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di http://localhost:${PORT}`);
});
