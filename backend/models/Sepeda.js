const db = require("../config/db");

const Sepeda = {
  getAll: (callback) => {
    db.query("SELECT * FROM sepeda", callback);
  },

  create: (data, callback) => {
    db.query("INSERT INTO sepeda SET ?", data, callback);
  },

  updateStatus: (id, status, callback) => {
    db.query("UPDATE sepeda SET status = ? WHERE id = ?", [status, id], callback);
  },
};

module.exports = Sepeda;
