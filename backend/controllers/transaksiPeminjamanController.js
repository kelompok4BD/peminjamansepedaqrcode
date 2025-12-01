const TransaksiPeminjaman = require("../models/transaksiPeminjaman");
const QRCode = require("qrcode");
const db = require("../config/db");

exports.getAll = (req, res) => {
  TransaksiPeminjaman.getAll((err, results) => {
    if (err) {
      console.error("Error ambil data transaksi:", err);
      res.status(500).json({ message: "Gagal ambil data transaksi", error: err });
    } else {
      console.log("Data transaksi:", results);
      res.json(results);
    }
  });
};

exports.create = (req, res) => {
  const { id_user, id_sepeda, metode_jaminan } = req.body;
  
  console.log('📝 Create Transaksi - Body:', { id_user, id_sepeda, metode_jaminan });
  
  // Validasi ketat
  if (!id_user || !id_sepeda) {
    console.error('❌ Validasi gagal: id_user atau id_sepeda kosong');
    return res.status(400).json({ 
      success: false,
      message: "ID user dan ID sepeda diperlukan",
      received: { id_user, id_sepeda }
    });
  }

  const numIdUser = parseInt(id_user, 10);
  const numIdSepeda = parseInt(id_sepeda, 10);
  
  if (isNaN(numIdUser) || isNaN(numIdSepeda) || numIdUser <= 0 || numIdSepeda <= 0) {
    console.error('❌ Validasi gagal: ID tidak valid -', { numIdUser, numIdSepeda });
    return res.status(400).json({ 
      success: false,
      message: "ID user dan ID sepeda harus berupa angka positif",
      received: { id_user, id_sepeda, parsed: { numIdUser, numIdSepeda } }
    });
  }

  const data = {
    id_user: numIdUser,
    id_sepeda: numIdSepeda,
    metode_jaminan: metode_jaminan || "KTM"
  };
  
  console.log('✅ Validasi passed, data:', data);

  // Start DB transaction for atomicity
  db.beginTransaction((err) => {
    if (err) {
      console.error('❌ Begin transaction failed:', err);
      return res.status(500).json({
        success: false,
        message: "Gagal memulai transaksi database",
        error: err
      });
    }

    // Step 1: Insert into transaksi_peminjaman
    const insertTransaksiSql = 'INSERT INTO transaksi_peminjaman (id_user, id_sepeda, waktu_pinjam, status_transaksi, metode_jaminan) VALUES (?, ?, NOW(), ?, ?)';
    db.query(insertTransaksiSql, [numIdUser, numIdSepeda, 'Dipinjam', data.metode_jaminan], (err1, result1) => {
      if (err1) {
        console.error('❌ Insert transaksi failed:', err1);
        return db.rollback(() => {
          res.status(500).json({
            success: false,
            message: "Gagal membuat transaksi peminjaman",
            error: err1
          });
        });
      }

      const transactionId = result1.insertId;
      console.log('✅ Transaksi inserted, id:', transactionId);

      // Step 2: Update sepeda status to 'Dipinjam'
      const updateSepedaSql = 'UPDATE sepeda SET status_saat_ini = ? WHERE id_sepeda = ?';
      db.query(updateSepedaSql, ['Dipinjam', numIdSepeda], (err2, result2) => {
        if (err2) {
          console.error('❌ Update sepeda status failed:', err2);
          return db.rollback(() => {
            res.status(500).json({
              success: false,
              message: "Gagal update status sepeda",
              error: err2
            });
          });
        }

        console.log('✅ Sepeda status updated');

        // Step 3: Generate QR code and insert into qr_code table
        const qrData = `SEPEDA_${numIdSepeda}_TRANSAKSI_${transactionId}_USER_${numIdUser}`;
        QRCode.toDataURL(qrData, async (qrErr, qrCode) => {
          if (qrErr) {
            console.error('❌ Generate QR code failed:', qrErr);
            return db.rollback(() => {
              res.status(500).json({
                success: false,
                message: "Gagal generate QR code",
                error: qrErr
              });
            });
          }

          const insertQrSql = 'INSERT INTO qr_code (id_sepeda, waktu_generate, status_qr, kode_qr) VALUES (?, NOW(), ?, ?)';
          db.query(insertQrSql, [numIdSepeda, 'Aktif', qrData], (err3, result3) => {
            if (err3) {
              console.error('❌ Insert qr_code failed:', err3);
              return db.rollback(() => {
                res.status(500).json({
                  success: false,
                  message: "Gagal menyimpan QR code ke database",
                  error: err3
                });
              });
            }

            console.log('✅ QR code inserted, id:', result3.insertId);

            // All success: commit transaction
            db.commit((commitErr) => {
              if (commitErr) {
                console.error('❌ Commit transaction failed:', commitErr);
                return db.rollback(() => {
                  res.status(500).json({
                    success: false,
                    message: "Gagal commit transaksi",
                    error: commitErr
                  });
                });
              }

              console.log('✅ Transaction committed successfully');
              res.json({
                success: true,
                message: "Sepeda berhasil dipinjam! Scan QR code untuk membuka kunci.",
                data: {
                  id_transaksi: transactionId,
                  id_sepeda: numIdSepeda,
                  id_user: numIdUser,
                  qr_code: qrCode,
                  qr_data: qrData,
                  id_qr: result3.insertId
                }
              });
            });
          });
        });
      });
    });
  });
};

exports.updateStatus = (req, res) => {
  const id = req.params.id;
  const { status } = req.body;
  TransaksiPeminjaman.updateStatus(id, status, (err, result) => {
    if (err) {
      console.error("Error update status:", err);
      res.status(500).json({ message: "Gagal update status", error: err });
    } else {
      res.json({ message: "Status berhasil diupdate", result });
    }
  });
};

exports.selesaiPinjam = (req, res) => {
  const { id_transaksi, id_sepeda } = req.body;

  if (!id_transaksi || !id_sepeda) {
    return res.status(400).json({ 
      success: false,
      message: "ID transaksi dan ID sepeda diperlukan" 
    });
  }

  console.log('📝 Selesai Pinjam - Body:', { id_transaksi, id_sepeda });

  db.beginTransaction((err) => {
    if (err) {
      console.error('❌ Begin transaction failed:', err);
      return res.status(500).json({
        success: false,
        message: "Gagal memulai transaksi database",
        error: err
      });
    }

    // Step 1: Update transaksi_peminjaman status to 'Dikembalikan'
    const updateTransaksiSql = `
      UPDATE transaksi_peminjaman 
      SET status_transaksi = 'Dikembalikan', 
          waktu_kembali = NOW()
      WHERE id_transaksi = ?
    `;

    db.query(updateTransaksiSql, [id_transaksi], (err1, result1) => {
      if (err1) {
        console.error('❌ Update transaksi failed:', err1);
        return db.rollback(() => {
          res.status(500).json({
            success: false,
            message: "Gagal update status transaksi",
            error: err1
          });
        });
      }

      console.log('✅ Transaksi updated to Dikembalikan');

      // Step 2: Update sepeda status to 'Tersedia'
      const updateSepedaSql = `
        UPDATE sepeda 
        SET status_saat_ini = 'Tersedia'
        WHERE id_sepeda = ?
      `;

      db.query(updateSepedaSql, [id_sepeda], (err2, result2) => {
        if (err2) {
          console.error('❌ Update sepeda failed:', err2);
          return db.rollback(() => {
            res.status(500).json({
              success: false,
              message: "Gagal update status sepeda",
              error: err2
            });
          });
        }

        console.log('✅ Sepeda updated to Tersedia');

        // Step 3: Commit transaction
        db.commit((err3) => {
          if (err3) {
            console.error('❌ Commit failed:', err3);
            return db.rollback(() => {
              res.status(500).json({
                success: false,
                message: "Gagal commit perubahan",
                error: err3
              });
            });
          }

          console.log('✅ Transaction committed successfully');
          res.json({
            success: true,
            message: "✅ Sepeda berhasil dikembalikan",
            id_transaksi,
            id_sepeda
          });
        });
      });
    });
  });
};
