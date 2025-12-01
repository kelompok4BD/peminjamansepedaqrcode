const Sepeda = require("../models/sepeda");
const db = require("../config/db");
const logActivity = require('../utils/logActivity');

// =========================
// GET semua sepeda
// =========================
exports.getAllSepeda = async (req, res) => {
  try {
    const data = await Sepeda.getAll();
    res.json({ data });
  } catch (err) {
    console.error("❌ Gagal ambil data sepeda:", err);
    res.status(500).json({ message: "Gagal ambil data sepeda" });
  }
};

// =========================
// CREATE sepeda baru
// =========================
exports.createSepeda = async (req, res) => {
  const {
    merk, tahun, status, kondisi,
    kode_qr, merk_model, tahun_pembelian,
    status_saat_ini, status_perawatan,
    kode_qr_sepeda, id_stasiun
  } = req.body || {};

  const finalMerk = (merk ?? merk_model ?? "").trim();
  const finalTahun = tahun ?? tahun_pembelian ?? new Date().getFullYear();
  const finalStatus = status ?? status_saat_ini ?? "Tersedia";
  const finalKondisi = kondisi ?? status_perawatan ?? "Baik";
  const finalKodeQr = kode_qr ?? kode_qr_sepeda ?? `QR${Date.now()}`;

  if (!finalMerk) {
    return res.status(400).json({ message: "Merk/model sepeda wajib diisi!" });
  }

  try {
    const result = await Sepeda.create({
      merk: finalMerk,
      tahun: finalTahun,
      status: finalStatus,
      kondisi: finalKondisi,
      kode_qr: finalKodeQr,
      id_stasiun: id_stasiun || null
    });

    res.status(201).json({
      success: true,
      data: {
        id: result.insertId,
        merk: finalMerk,
        tahun: finalTahun,
        status: finalStatus,
        kondisi: finalKondisi,
        kode_qr: finalKodeQr,
        id_stasiun: id_stasiun || null,
      },
      message: "Sepeda berhasil ditambahkan",
    });

    logActivity(req, 'Create Sepeda', `Menambahkan sepeda id=${result.insertId} merk=${finalMerk}`);
  } catch (err) {
    console.error("❌ Gagal menambah sepeda:", err.sqlMessage || err);
    res.status(500).json({ message: "Gagal menambah sepeda" });
  }
};

// =========================
// UPDATE status sepeda
// =========================
exports.updateStatus = async (req, res) => {
  const { id } = req.params;
  const { status, kondisi } = req.body;

  if (!status) {
    return res.status(400).json({ message: "Status wajib diisi!" });
  }

  try {
    await Sepeda.updateStatus(id, status, kondisi);
    res.json({ success: true, message: "Status sepeda diperbarui!" });

    logActivity(req, 'Update Status Sepeda', `Update status sepeda id=${id} => ${status}`);
  } catch (err) {
    console.error("❌ Gagal update status:", err);
    res.status(500).json({ message: "Gagal update status sepeda" });
  }
};

// =========================
// DELETE sepeda
// =========================
exports.deleteSepeda = async (req, res) => {
  const { id } = req.params;

  try {
    await Sepeda.delete(id);
    res.json({ success: true, message: "Sepeda berhasil dihapus!" });

    logActivity(req, 'Delete Sepeda', `Hapus sepeda id=${id}`);
  } catch (err) {
    console.error("❌ Gagal hapus sepeda:", err);
    res.status(500).json({ message: "Gagal hapus sepeda" });
  }
};

// =========================
// UPDATE data sepeda
// =========================
exports.updateSepeda = async (req, res) => {
  const { id } = req.params;
  const {
    merk_model, tahun_pembelian, status_saat_ini,
    status_perawatan, kode_qr_sepeda, id_stasiun
  } = req.body;

  if (!merk_model) {
    return res.status(400).json({ message: "Merk/Model wajib diisi!" });
  }

  try {
    await Sepeda.update(id, {
      merk_model,
      tahun_pembelian,
      status_saat_ini,
      status_perawatan,
      kode_qr_sepeda,
      id_stasiun,
    });

    res.json({ success: true, message: "Data sepeda berhasil diperbarui!" });

    logActivity(req, 'Update Sepeda', `Update data sepeda id=${id}`);
  } catch (err) {
    console.error("❌ Gagal update sepeda:", err);
    res.status(500).json({ message: "Gagal update data sepeda" });
  }
};

// ========================================================
// PINJAM SEPEDA (pakai async-await juga)
// ========================================================
exports.pinjamSepeda = async (req, res) => {
  const { id_user, id_sepeda } = req.body;

  if (!id_user || !id_sepeda) {
    return res.status(400).json({
      success: false,
      message: "ID user dan ID sepeda wajib diisi!"
    });
  }

  try {
    // 1. update status sepeda
    await db.query(
      `UPDATE sepeda SET status_saat_ini = 'Dipinjam' WHERE id_sepeda = ?`,
      [id_sepeda]
    );

    // 2. insert transaksi
    const [insert] = await db.query(
      `
      INSERT INTO transaksi_peminjaman (id_user, id_sepeda, waktu_pinjam, status_transaksi, metode_jaminan)
      VALUES (?, ?, NOW(), 'Dipinjam', 'KTM')
      `,
      [id_user, id_sepeda]
    );

    // 3. ambil QR sepeda
    const [qrRows] = await db.query(
      `SELECT kode_qr_sepeda FROM sepeda WHERE id_sepeda = ?`,
      [id_sepeda]
    );

    const qrCode = qrRows[0]?.kode_qr_sepeda || null;

    res.json({
      success: true,
      message: "Peminjaman berhasil",
      data: {
        id_transaksi: insert.insertId,
        id_sepeda,
        kode_qr: qrCode,
      },
    });

    logActivity(req, 'Pinjam Sepeda', `User id=${id_user} meminjam sepeda id=${id_sepeda}`);
  } catch (err) {
    console.error("❌ Error pinjam sepeda:", err);
    res.status(500).json({ success: false, message: "Gagal meminjam sepeda" });
  }
};
