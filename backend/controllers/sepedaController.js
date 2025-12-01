const Sepeda = require("../models/Sepeda");
const db = require("../config/db");
const logActivity = require('../utils/logActivity');

// ✅ GET semua sepeda
exports.getAllSepeda = (req, res) => {
  Sepeda.getAll((err, data) => {
    if (err) {
      console.error("❌ Gagal ambil data sepeda:", err);
      return res.status(500).json({ message: "Gagal ambil data sepeda" });
    }
    res.json({ data });
  });
};

// ✅ CREATE sepeda baru
exports.createSepeda = (req, res) => {
  const {
    merk,
    tahun,
    status,
    kondisi,
    kode_qr,
    merk_model,
    tahun_pembelian,
    status_saat_ini,
    status_perawatan,
    kode_qr_sepeda,
    id_stasiun,
  } = req.body || {};

  const finalMerk = (merk ?? merk_model ?? "").toString().trim();
  const finalTahun = tahun ?? tahun_pembelian ?? new Date().getFullYear();
  const finalStatus = status ?? status_saat_ini ?? "Tersedia";
  const finalKondisi = kondisi ?? status_perawatan ?? "Baik";
  const finalKodeQr = kode_qr ?? kode_qr_sepeda ?? `QR${Date.now()}`;

  if (!finalMerk) {
    return res.status(400).json({ message: "Merk/model sepeda wajib diisi!" });
  }

  Sepeda.create(
    {
      merk: finalMerk,
      tahun: finalTahun,
      status: finalStatus,
      kondisi: finalKondisi,
      kode_qr: finalKodeQr,
      id_stasiun: id_stasiun || null,
    },
    (err, result) => {
      if (err) {
        console.error("❌ Gagal menambah sepeda:", err.sqlMessage || err.message || err);
        return res
          .status(500)
          .json({ message: "Gagal menambah sepeda", error: err.message || err });
      }

      res.status(201).json({
        success: true,
        data: {
          id: result?.insertId || null,
          merk: finalMerk,
          tahun: finalTahun,
          status: finalStatus,
          kondisi: finalKondisi,
          kode_qr: finalKodeQr,
          id_stasiun: id_stasiun || null,
        },
        message: "Sepeda berhasil ditambahkan",
      });
      // Catat aktivitas (non-blocking)
      logActivity(req, 'Create Sepeda', `Menambahkan sepeda id=${result?.insertId || 'unknown'} merk=${finalMerk}`);
    }
  );
};

// ✅ UPDATE status sepeda (misal: tersedia / dipinjam / perawatan)
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
      message: "Status sepeda diperbarui!",
    });
    // Catat aktivitas (non-blocking)
    logActivity(req, 'Update Status Sepeda', `Update status sepeda id=${id} => ${status}`);
  });
};

// ✅ DELETE sepeda
exports.deleteSepeda = (req, res) => {
  const { id } = req.params;

  Sepeda.delete(id, (err) => {
    if (err) {
      console.error("❌ Gagal hapus sepeda:", err);
      return res.status(500).json({ message: "Gagal hapus sepeda" });
    }
    res.json({
      success: true,
      message: "Sepeda berhasil dihapus!",
    });
    // Catat aktivitas (non-blocking)
    logActivity(req, 'Delete Sepeda', `Hapus sepeda id=${id}`);
  });
};

// ✅ UPDATE data sepeda (edit merk, tahun, perawatan, dsb)
exports.updateSepeda = (req, res) => {
  const { id } = req.params;
  const { merk_model, tahun_pembelian, status_saat_ini, status_perawatan, kode_qr_sepeda, id_stasiun } =
    req.body;

  if (!merk_model) {
    return res.status(400).json({ message: "Merk/Model wajib diisi!" });
  }

  Sepeda.update(
    id,
    {
      merk_model,
      tahun_pembelian,
      status_saat_ini,
      status_perawatan,
      kode_qr_sepeda,
      id_stasiun,
    },
    (err) => {
      if (err) {
        console.error("❌ Gagal update sepeda:", err);
        return res.status(500).json({ message: "Gagal update data sepeda" });
      }
      res.json({
        success: true,
        message: "Data sepeda berhasil diperbarui!",
      });
      // Catat aktivitas (non-blocking)
      logActivity(req, 'Update Sepeda', `Update data sepeda id=${id}`);
    }
  );
};

// ✅ FITUR BARU: Pinjam Sepeda (generate QR otomatis + catat transaksi)
exports.pinjamSepeda = (req, res) => {
  const { id_user, id_sepeda } = req.body;

  if (!id_user || !id_sepeda) {
    return res
      .status(400)
      .json({ success: false, message: "ID user dan ID sepeda wajib diisi!" });
  }

  // 1️⃣ Update status sepeda jadi Dipinjam
  const updateSql = `UPDATE sepeda SET status_saat_ini = 'Dipinjam' WHERE id_sepeda = ?`;

  db.query(updateSql, [id_sepeda], (err) => {
    if (err) {
      console.error("❌ Gagal update status sepeda:", err);
      return res
        .status(500)
        .json({ success: false, message: "Gagal update status sepeda" });
    }

    // 2️⃣ Tambahkan record ke transaksi_peminjaman
    const insertSql = `
      INSERT INTO transaksi_peminjaman (id_user, id_sepeda, waktu_pinjam, status_transaksi, metode_jaminan)
      VALUES (?, ?, NOW(), 'Dipinjam', 'KTM')
    `;

    db.query(insertSql, [id_user, id_sepeda], (err2, result) => {
      if (err2) {
        console.error("❌ Gagal tambah transaksi:", err2);
        return res
          .status(500)
          .json({ success: false, message: "Gagal mencatat transaksi" });
      }

      // 3️⃣ Ambil kode QR sepeda untuk ditampilkan ke user
      const qrSql = `SELECT kode_qr_sepeda FROM sepeda WHERE id_sepeda = ?`;
      db.query(qrSql, [id_sepeda], (err3, qrRows) => {
        if (err3) {
          console.error("❌ Gagal ambil kode QR:", err3);
          return res
            .status(500)
            .json({ success: false, message: "Gagal ambil kode QR" });
        }

        const qrCode = qrRows[0]?.kode_qr_sepeda || null;
        res.json({
          success: true,
          message: "Peminjaman berhasil",
          data: {
            id_transaksi: result.insertId,
            id_sepeda,
            kode_qr: qrCode,
          },
        });
        // Catat aktivitas (non-blocking)
        logActivity(req, 'Pinjam Sepeda', `User id=${id_user} meminjam sepeda id=${id_sepeda} transaksi=${result.insertId}`);
      });
    });
  });
};
