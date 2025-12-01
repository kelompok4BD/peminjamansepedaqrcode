const db = require('../config/db').promise();

const Riwayat = {
  getAll: async () => {
    const sql = `
      SELECT * 
      FROM riwayat_pemeliharaan 
      ORDER BY tanggal_mulai DESC
    `;
    const [rows] = await db.query(sql);
    return rows;
  }
};

module.exports = Riwayat;
