const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'peminjaman_sepeda' // harus sama dengan nama DB kamu di phpMyAdmin
});

db.connect((err) => {
  if (err) {
    console.error('Koneksi database gagal:', err);
  } else {
    console.log('✅ Connected to MySQL');
  }
});

module.exports = db;
