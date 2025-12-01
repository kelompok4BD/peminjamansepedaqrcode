const mysql = require("mysql2");

// Gunakan environment variable jika ada (Render / cloud)
const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "peminjaman_sepeda",
  port: process.env.DB_PORT || 3306,
  connectTimeout: 10000, // biar gak lama nunggu connect
});

db.connect((err) => {
  if (err) {
    console.error("❌ Gagal konek ke database:", err.message);
  } else {
    console.log("✅ Connected to database:", process.env.DB_HOST || "localhost");
  }
});

module.exports = db;