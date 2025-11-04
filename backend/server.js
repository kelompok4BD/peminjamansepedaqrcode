const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const db = require("./config/db");

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Import routes
const sepedaRoutes = require("./routes/sepedaRoutes");
const userRoutes = require("./routes/userRoutes");
const peminjamanRoutes = require("./routes/peminjamanRoutes");
const authRoutes = require("./routes/authRoutes"); // ✅ Route login
const pengaturanRoutes = require("./routes/pengaturanRoutes");
const stasiunRoutes = require("./routes/stasiunRoutes");
const riwayatPemeliharaanRoutes = require("./routes/riwayatPemeliharaanRoutes");

// Gunakan routes
app.use("/api/sepeda", sepedaRoutes);
app.use("/api/user", userRoutes);
app.use("/api/peminjaman", peminjamanRoutes);
app.use("/api", authRoutes); // ✅ Penting! untuk /api/login
app.use("/api/pengaturan", pengaturanRoutes);
app.use("/api/stasiun", stasiunRoutes);
app.use("/api/riwayat_pemeliharaan", riwayatPemeliharaanRoutes);

// Cek koneksi database
db.connect((err) => {
  if (err) {
    console.error("❌ Gagal konek ke MySQL:", err);
  } else {
    console.log("✅ Terhubung ke MySQL Database peminjaman_sepeda");
  }
});

// Endpoint root
app.get("/", (req, res) => {
  res.send("🚴‍♂️ Backend Peminjaman Sepeda Kampus Aktif!");
});

// Jalankan server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`✅ Server berjalan di http://localhost:${PORT}`);
});
