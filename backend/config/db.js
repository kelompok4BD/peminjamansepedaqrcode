const mysql = require("mysql2");

// Deteksi penggunaan SSL (Render kadang butuh, AlwaysData nggak wajib)
const useSSL =
  process.env.DB_SSL === "true" ||
  process.env.RENDER === "true" ||
  false;

const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "peminjamansepeda_tes",
  port: process.env.DB_PORT || 3306,

  ssl: useSSL
    ? { rejectUnauthorized: false }
    : false,

  connectTimeout: 10000,
});

db.connect((err) => {
  if (err) {
    console.error("❌ Gagal konek ke database:", err.message);
  } else {
    console.log("✅ Koneksi database berhasil ke:", process.env.DB_HOST);
  }
});

module.exports = db;
