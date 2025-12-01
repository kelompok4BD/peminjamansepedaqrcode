const mysql = require("mysql2");

const useSSL =
  process.env.DB_SSL === "true" ||
  process.env.RENDER === "true";

const db = mysql.createConnection({
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASS || "",
  database: process.env.DB_NAME || "sql12810177",  // ⬅️ DIGANTI
  port: process.env.DB_PORT || 3306,

  ssl: useSSL ? { rejectUnauthorized: false } : false,

  connectTimeout: 10000,
});

db.connect((err) => {
  if (err) {
    console.error("❌ Gagal konek ke database:", err.code, err.message);
  } else {
    console.log("✅ Berhasil konek ke DB:", db.config.database);
  }
});

module.exports = db;
