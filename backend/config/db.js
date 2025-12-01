const mysql = require("mysql2");

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 3306,

  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,

  enableKeepAlive: true,
  keepAliveInitialDelay: 0,

  ssl: false,
});

// Test koneksi awal
pool.getConnection((err, conn) => {
  if (err) {
    console.error("❌ Gagal konek ke database:", err?.message || err);
  } else {
    console.log("✅ Koneksi database berhasil ke:", process.env.DB_HOST);
    conn.release();
  }
});

// Keep-alive
setInterval(() => {
  pool.query("SELECT 1", (err) => {
    if (err) {
      console.debug("⚠️ DB ping error (ignored):", err?.message || err);
    }
  });
}, 30000);

// Export: callback + promise
const db = pool;        // alias
db.promise = pool.promise();  // inject promise API ke object

module.exports = db;
