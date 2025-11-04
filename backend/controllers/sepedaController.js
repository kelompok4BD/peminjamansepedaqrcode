const db = require("../config/db");

// GET semua sepeda
exports.getAllSepeda = (req, res) => {
  const sql = "SELECT * FROM sepeda";
  db.query(sql, (err, results) => {
    if (err) {
      console.error("❌ Gagal ambil data sepeda:", err);
      return res.status(500).json({ message: "Gagal ambil data sepeda" });
    }

    // Map database fields to response format
    const data = results.map((s) => ({
      id: s.id_sepeda,
      merk: s.merk_model || "Tidak diketahui",
      status: s.status_saat_ini || "Tersedia",
      tahun: s.tahun_pembelian,
      kondisi: s.status_perawatan,
      kode_qr: s.kode_qr_sepeda
    }));

    res.json(data);
  });
};

// POST tambah sepeda baru
exports.createSepeda = (req, res) => {
  const { merk, tahun, status, kondisi, kode_qr } = req.body;

  if (!merk || merk.trim() === "") {
    return res.status(400).json({ message: "Merk/model sepeda wajib diisi!" });
  }

  const sql = "INSERT INTO sepeda (merk_model, tahun_pembelian, status_saat_ini, status_perawatan, kode_qr_sepeda) VALUES (?, ?, ?, ?, ?)";
  db.query(sql, [
    merk, 
    tahun || new Date().getFullYear(), 
    status || "Tersedia",
    kondisi || "Baik",
    kode_qr || `QR${Date.now()}`
  ], (err, result) => {
    if (err) {
      console.error("❌ Gagal menambah sepeda:", err);
      return res.status(500).json({ message: "Gagal menambah sepeda" });
    }

    res.status(201).json({
      id: result.insertId,
      merk,
      tahun,
      status: status || "Tersedia",
      kondisi: kondisi || "Baik",
      kode_qr: kode_qr || `QR${Date.now()}`
    });
  });
};

// PUT update status sepeda
exports.updateStatus = (req, res) => {
  const { id } = req.params;
  const { status, kondisi } = req.body;

  if (!status) {
    return res.status(400).json({ message: "Status wajib diisi!" });
  }

  const sql = "UPDATE sepeda SET status_saat_ini = ?, status_perawatan = ? WHERE id_sepeda = ?";
  db.query(sql, [status, kondisi || "Baik", id], (err) => {
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
  const sql = "DELETE FROM sepeda WHERE id_sepeda = ?";
  db.query(sql, [id], (err) => {
    if (err) {
      console.error("❌ Gagal hapus sepeda:", err);
      return res.status(500).json({ message: "Gagal hapus sepeda" });
    }
    res.json({ message: "Sepeda berhasil dihapus!" });
  });
};

  // PUT update sepeda (edit all fields)
  exports.updateSepeda = (req, res) => {
    const { id } = req.params;
    const { merk_model, tahun_pembelian, status_saat_ini, status_perawatan, kode_qr_sepeda } = req.body;

    if (!merk_model) {
      return res.status(400).json({ message: "Merk/Model wajib diisi!" });
    }

    const sql = `
      UPDATE sepeda 
      SET merk_model = ?, 
          tahun_pembelian = ?, 
          status_saat_ini = ?, 
          status_perawatan = ?,
          kode_qr_sepeda = ?
      WHERE id_sepeda = ?
    `;
  
    db.query(sql, [
      merk_model,
      tahun_pembelian,
      status_saat_ini || "Tersedia",
      status_perawatan || "Baik",
      kode_qr_sepeda,
      id
    ], (err) => {
      if (err) {
        console.error("❌ Gagal update sepeda:", err);
        return res.status(500).json({ message: "Gagal update data sepeda" });
      }
      res.json({ message: "Data sepeda berhasil diperbarui!" });
    });
  };
