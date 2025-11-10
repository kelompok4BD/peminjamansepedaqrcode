const Stasiun = require("../models/StasiunSepeda");

exports.getAllStasiun = (req, res) => {
  Stasiun.getAll((err, data) => {
    if (err) {
      console.error("❌ Gagal ambil data stasiun:", err);
      return res.status(500).json({ message: "Gagal ambil data stasiun" });
    }
    res.json({ data });
  });
};
