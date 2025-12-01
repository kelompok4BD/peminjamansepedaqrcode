const { pool: db } = require('../config/db');

const Pengaturan = {
  getAll: (callback) => {
    db.query("SELECT * FROM pengaturan_sistem", callback);
  },

  getById: (id, callback) => {
    db.query(
      "SELECT * FROM pengaturan_sistem WHERE id_pengaturan = ?",
      [id],
      callback
    );
  },

  update: (id, data, callback) => {
    const fields = [];
    const values = [];
    
    if (data.batas_waktu_pinjam !== undefined) {
      fields.push('batas_waktu_pinjam = ?');
      values.push(data.batas_waktu_pinjam);
    }
    if (data.tarif_denda_per_jam !== undefined) {
      fields.push('tarif_denda_per_jam = ?');
      values.push(data.tarif_denda_per_jam);
    }
    if (data.informasi_kontak_darurat !== undefined) {
      fields.push('informasi_kontak_darurat = ?');
      values.push(data.informasi_kontak_darurat);
    }
    if (data.batas_wilayah_gps !== undefined) {
      fields.push('batas_wilayah_gps = ?');
      values.push(data.batas_wilayah_gps);
    }
    
    if (fields.length === 0) {
      return callback(null, { affectedRows: 0 });
    }
    
    values.push(id);
    const sql = `UPDATE pengaturan_sistem SET ${fields.join(', ')} WHERE id_pengaturan = ?`;
    db.query(sql, values, callback);
  }
};

module.exports = Pengaturan;
