const QRCode = require("qrcode");
const { promise: db } = require("../config/db"); 
const TransaksiModel = require("../models/transaksiPeminjaman");
const logActivity = require("../utils/logActivity");

function normalizeStatus(s) {
  if (!s) return s;
  const t = s.toString().trim().toLowerCase();
  if (["dikembalikan", "kembali", "returned"].includes(t)) return "Dikembalikan";
  if (["dipinjam", "pinjam", "borrowed"].includes(t)) return "Dipinjam";
  return s.charAt(0).toUpperCase() + s.slice(1);
}

exports.getAll = async (req, res) => {
  try {
    const rows = await TransaksiModel.getAll();
    res.json(rows);
  } catch (err) {
    console.error("Error ambil data transaksi:", err);
    res.status(500).json({ message: "Gagal ambil data transaksi", error: err.message || err });
  }
};

exports.create = async (req, res) => {
  const { id_user, id_sepeda, metode_jaminan } = req.body || {};
  if (!id_user || !id_sepeda) {
    return res.status(400).json({
      success: false,
      message: "ID user dan ID sepeda diperlukan",
    });
  }

  const numIdUser = Number(id_user);
  const numIdSepeda = Number(id_sepeda);
  if (!Number.isInteger(numIdUser) || numIdUser <= 0 || !Number.isInteger(numIdSepeda) || numIdSepeda <= 0) {
    return res.status(400).json({
      success: false,
      message: "ID user dan ID sepeda harus berupa angka positif",
    });
  }

  let conn;
  try {
    conn = await db.getConnection();
    await conn.beginTransaction();

    // 1) Pastikan user ada (opsional: jika system boleh guest, skip)
    const [userRows] = await conn.query("SELECT id_NIM_NIP FROM `user` WHERE id_NIM_NIP = ? LIMIT 1", [numIdUser]);
    if (userRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ success: false, message: "User tidak ditemukan" });
    }

    // 2) Pastikan sepeda ada & tersedia
    const [sepRows] = await conn.query("SELECT id_sepeda, status_saat_ini FROM `sepeda` WHERE id_sepeda = ? LIMIT 1", [numIdSepeda]);
    if (sepRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ success: false, message: "Sepeda tidak ditemukan" });
    }
    const sep = sepRows[0];
    if (sep.status_saat_ini && sep.status_saat_ini.toLowerCase() !== "tersedia") {
      await conn.rollback();
      return res.status(409).json({ success: false, message: `Sepeda tidak tersedia (status: ${sep.status_saat_ini})` });
    }

    // 3) Insert transaksi
    const [insertTrans] = await conn.query(
      `INSERT INTO transaksi_peminjaman (id_user, id_sepeda, waktu_pinjam, status_transaksi, metode_jaminan)
       VALUES (?, ?, NOW(), ?, ?)`,
      [numIdUser, numIdSepeda, "Dipinjam", metode_jaminan || "KTM"]
    );
    const transactionId = insertTrans.insertId;

    // 4) Update sepeda jadi Dipinjam
    await conn.query(`UPDATE \`sepeda\` SET status_saat_ini = ? WHERE id_sepeda = ?`, ["Dipinjam", numIdSepeda]);

    // 5) Generate QR (text + base64)
    const qrData = `SEPEDA_${numIdSepeda}_TRANSAKSI_${transactionId}_USER_${numIdUser}_${Date.now()}`;
    const qrImageBase64 = await QRCode.toDataURL(qrData); // base64 data URL

    // 6) Simpan ke tabel qr_code (simpan kedua: kode_qr (text) & qr_image (base64))
    const [insertQr] = await conn.query(
      `INSERT INTO qr_code (id_sepeda, waktu_generate, status_qr, kode_qr, qr_image) VALUES (?, NOW(), ?, ?, ?)`,
      [numIdSepeda, "Aktif", qrData, qrImageBase64]
    );

    await conn.commit();

    // Log activity (non-blocking)
    try { logActivity(req, "Pinjam Sepeda", `User id=${numIdUser} meminjam sepeda id=${numIdSepeda} transaksi=${transactionId}`); } catch(e){}

    res.json({
      success: true,
      message: "Sepeda berhasil dipinjam! Scan QR code untuk membuka kunci.",
      data: {
        id_transaksi: transactionId,
        id_sepeda: numIdSepeda,
        id_user: numIdUser,
        qr_data: qrData,
        qr_image: qrImageBase64,
        id_qr: insertQr.insertId
      }
    });
  } catch (err) {
    console.error("❌ Create transaksi error:", err);
    if (conn) {
      try { await conn.rollback(); } catch (e) { console.error("Rollback error:", e); }
    }
    res.status(500).json({ success: false, message: "Gagal membuat transaksi peminjaman", error: err.message || err });
  } finally {
    if (conn) try { conn.release(); } catch (e) {}
  }
};

exports.updateStatus = async (req, res) => {
  const id = req.params.id;
  const { status } = req.body;
  if (!status) return res.status(400).json({ message: "Status wajib dikirim" });

  const normalized = normalizeStatus(status);
  let conn;
  try {
    conn = await db.getConnection();
    await conn.beginTransaction();

    if (normalized === "Dikembalikan") {
      // update transaksi -> set waktu_kembali & status
      const [upd] = await conn.query(
        `UPDATE transaksi_peminjaman SET status_transaksi = ?, waktu_kembali = NOW() WHERE id_transaksi = ?`,
        [normalized, id]
      );
      if (upd.affectedRows === 0) {
        await conn.rollback();
        return res.status(404).json({ message: "Transaksi tidak ditemukan" });
      }

      // ambil id_sepeda
      const [rows] = await conn.query(`SELECT id_sepeda FROM transaksi_peminjaman WHERE id_transaksi = ? LIMIT 1`, [id]);
      if (rows.length > 0) {
        await conn.query(`UPDATE \`sepeda\` SET status_saat_ini = 'Tersedia' WHERE id_sepeda = ?`, [rows[0].id_sepeda]);
      }

      await conn.commit();
      try { logActivity(req, "Update Status Transaksi", `Transaksi id=${id} => ${normalized}`); } catch(e){}
      return res.json({ message: "Status berhasil diupdate (Dikembalikan)" });
    } else {
      // hanya update status
      const [upd2] = await conn.query(`UPDATE transaksi_peminjaman SET status_transaksi = ? WHERE id_transaksi = ?`, [normalized, id]);
      if (upd2.affectedRows === 0) {
        await conn.rollback();
        return res.status(404).json({ message: "Transaksi tidak ditemukan" });
      }
      await conn.commit();
      try { logActivity(req, "Update Status Transaksi", `Transaksi id=${id} => ${normalized}`); } catch(e){}
      return res.json({ message: "Status berhasil diupdate" });
    }
  } catch (err) {
    console.error("Error update status:", err);
    if (conn) {
      try { await conn.rollback(); } catch (e) {}
    }
    res.status(500).json({ message: "Gagal update status", error: err.message || err });
  } finally {
    if (conn) try { conn.release(); } catch(e) {}
  }
};

exports.selesaiPinjam = async (req, res) => {
  const { id_transaksi, id_sepeda } = req.body || {};
  if (!id_transaksi || !id_sepeda) {
    return res.status(400).json({ success: false, message: "ID transaksi dan ID sepeda diperlukan" });
  }

  let conn;
  try {
    conn = await db.getConnection();
    await conn.beginTransaction();

    // pastikan transaksi ada & belum dikembalikan
    const [tRows] = await conn.query(`SELECT status_transaksi, id_sepeda FROM transaksi_peminjaman WHERE id_transaksi = ? LIMIT 1`, [id_transaksi]);
    if (tRows.length === 0) {
      await conn.rollback();
      return res.status(404).json({ success: false, message: "Transaksi tidak ditemukan" });
    }
    if (tRows[0].status_transaksi && tRows[0].status_transaksi.toLowerCase() === "dikembalikan") {
      await conn.rollback();
      return res.status(400).json({ success: false, message: "Transaksi sudah dikembalikan" });
    }

    // update transaksi
    await conn.query(
      `UPDATE transaksi_peminjaman SET status_transaksi = 'Dikembalikan', waktu_kembali = NOW() WHERE id_transaksi = ?`,
      [id_transaksi]
    );

    // update sepeda jadi tersedia
    await conn.query(`UPDATE \`sepeda\` SET status_saat_ini = 'Tersedia' WHERE id_sepeda = ?`, [id_sepeda]);

    await conn.commit();
    try { logActivity(req, "Selesai Pinjam", `Transaksi id=${id_transaksi} sepeda id=${id_sepeda}`); } catch(e){}
    res.json({ success: true, message: "✅ Sepeda berhasil dikembalikan", id_transaksi, id_sepeda });
  } catch (err) {
    console.error("Error selesaiPinjam:", err);
    if (conn) {
      try { await conn.rollback(); } catch (e) {}
    }
    res.status(500).json({ success: false, message: "Gagal menyelesaikan peminjaman", error: err.message || err });
  } finally {
    if (conn) try { conn.release(); } catch(e) {}
  }
};
