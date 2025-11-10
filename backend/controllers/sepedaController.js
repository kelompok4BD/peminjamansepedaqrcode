const Sepeda = require("../models/Sepeda");

// GET semua sepeda
exports.getAllSepeda = (req, res) => {
  Sepeda.getAll((err, data) => {
    if (err) {
      console.error("❌ Gagal ambil data sepeda:", err);
      return res.status(500).json({ message: "Gagal ambil data sepeda" });
    }
    res.json({ data });
  });
};

exports.createSepeda = (req, res) => {
  const {
    merk, tahun, status, kondisi, kode_qr,
    merk_model, tahun_pembelian, status_saat_ini, status_perawatan, kode_qr_sepeda
  } = req.body || {};

  const finalMerk = (merk ?? merk_model ?? "").toString().trim();
  const finalTahun = tahun ?? tahun_pembelian ?? new Date();
  const finalStatus = status ?? status_saat_ini ?? "Tersedia";
  const finalKondisi = kondisi ?? status_perawatan ?? "Baik";
  const finalKodeQr = kode_qr ?? kode_qr_sepeda ?? `QR${Date.now()}`;

  if (!finalMerk) {
    return res.status(400).json({ message: "Merk/model sepeda wajib diisi!" });
  }

  Sepeda.create({
    merk, merk_model: finalMerk,
    tahun, tahun_pembelian: finalTahun,
    status, status_saat_ini: finalStatus,
    kondisi, status_perawatan: finalKondisi,
    kode_qr, kode_qr_sepeda: finalKodeQr
  }, (err, result) => {
    if (err) {
      console.error("❌ Gagal menambah sepeda:", err.sqlMessage || err.message || err);
      return res.status(500).json({ message: "Gagal menambah sepeda", error: err.message || err });
    }

    res.status(201).json({
      success: true,
      data: {
        id: result && result.insertId ? result.insertId : null,
        merk: finalMerk,
        tahun: finalTahun,
        status: finalStatus,
        kondisi: finalKondisi,
        kode_qr: finalKodeQr
      },
      message: "Sepeda berhasil ditambahkan"
    });
  });
};

exports.updateStatus = (req, res) => {
  const { id } = req.params;
  const { status, kondisi } = req.body;

  if (!status) {
    return res.status(400).json({ message: "Status wajib diisi!" });
  }

  Sepeda.updateStatus(id, status, kondisi, (err) => {
    if (err) {
      console.error("❌ Gagal update status:", err);
      return res.status(500).json({ message: "Gagal update status" });
    }
    res.json({ 
      success: true,
      message: "Status sepeda diperbarui!" 
    });
  });
};

exports.deleteSepeda = (req, res) => {
  const { id } = req.params;
  
  Sepeda.delete(id, (err) => {
    if (err) {
      console.error("❌ Gagal hapus sepeda:", err);
      return res.status(500).json({ message: "Gagal hapus sepeda" });
    }
    res.json({ 
      success: true,
      message: "Sepeda berhasil dihapus!" 
    });
  });
};

exports.updateSepeda = (req, res) => {
  const { id } = req.params;
  const { merk_model, tahun_pembelian, status_saat_ini, status_perawatan, kode_qr_sepeda } = req.body;

  if (!merk_model) {
    return res.status(400).json({ message: "Merk/Model wajib diisi!" });
  }

  Sepeda.update(id, {
    merk_model,
    tahun_pembelian,
    status_saat_ini,
    status_perawatan,
    kode_qr_sepeda
  }, (err) => {
    if (err) {
      console.error("❌ Gagal update sepeda:", err);
      return res.status(500).json({ message: "Gagal update data sepeda" });
    }
    res.json({ 
      success: true,
      message: "Data sepeda berhasil diperbarui!" 
    });
  });
};
