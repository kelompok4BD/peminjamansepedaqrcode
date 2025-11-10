const TransaksiPeminjaman = require("../models/TransaksiPeminjaman");

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
  const data = req.body;
  TransaksiPeminjaman.create(data, (err, result) => {
    if (err) {
      console.error("Error buat transaksi:", err);
      res.status(500).json({ message: "Gagal buat transaksi", error: err });
    } else {
      res.json({ message: "Transaksi berhasil dibuat", result });
    }
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
