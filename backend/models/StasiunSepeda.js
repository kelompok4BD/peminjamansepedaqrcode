const db = require("../config/db");

const Stasiun = {
  getAll: (callback) => {
    const sql = "SELECT * FROM stasiun_sepeda";
    db.query(sql, (err, results) => {
      if (err) return callback(err);
      callback(null, results);
    });
  },
};

module.exports = Stasiun;
