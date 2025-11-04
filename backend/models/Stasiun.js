const db = require('../config/db');

const Stasiun = {
  getAll: (callback) => {
    db.query('SELECT * FROM stasiun_sepeda', callback);
  },
};

module.exports = Stasiun;
