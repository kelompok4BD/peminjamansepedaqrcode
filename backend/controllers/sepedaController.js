const db = require("../config/db");

// GET semua sepeda
exports.getAllSepeda = (req, res) => {
  const sql = "SELECT * FROM sepeda";
  db.query(sql, (err, results) => {
    if (err) {
      console.error("❌ Gagal ambil data sepeda:", err);
      return res.status(500).json({ message: "Gagal ambil data sepeda" });
    }

    // Biar gak kirim null ke Flutter
    const data = results.map((s) => ({
      id: s.id,
      nama_sepeda: s.nama_sepeda || "Tidak diketahui",
      status: s.status || "tersedia",
    }));

    res.json(data);
  });
};

// POST tambah sepeda baru
exports.createSepeda = (req, res) => {
  const { nama_sepeda, status } = req.body;

  if (!nama_sepeda || nama_sepeda.trim() === "") {
    return res.status(400).json({ message: "Nama sepeda wajib diisi!" });
  }

  const sql = "INSERT INTO sepeda (nama_sepeda, status) VALUES (?, ?)";
  db.query(sql, [nama_sepeda, status || "tersedia"], (err, result) => {
    if (err) {
      console.error("❌ Gagal menambah sepeda:", err);
      return res.status(500).json({ message: "Gagal menambah sepeda" });
    }

    res.status(201).json({
      id: result.insertId,
      nama_sepeda,
      status: status || "tersedia",
    });
  });
};

// PUT update status sepeda
exports.updateStatus = (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ message: "Status wajib diisi!" });
  }

  const sql = "UPDATE sepeda SET status = ? WHERE id = ?";
  db.query(sql, [status, id], (err) => {
    if (err) {
      console.error("❌ Gagal update status:", err);
      return res.status(500).json({ message: "Gagal update status" });
    }
    res.json({ message: "Status sepeda diperbarui!" });
  });
};

// DELETE hapus sepeda
exports.deleteSepeda = (req, res) => {
  const { id } = req.params;
  const sql = "DELETE FROM sepeda WHERE id = ?";
  db.query(sql, [id], (err) => {
    if (err) {
      console.error("❌ Gagal hapus sepeda:", err);
      return res.status(500).json({ message: "Gagal hapus sepeda" });
    }
    res.json({ message: "Sepeda berhasil dihapus!" });
  });
};
