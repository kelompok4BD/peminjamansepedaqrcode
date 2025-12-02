const express = require("express");
const router = express.Router();
const { promise: db } = require("../config/db");

// Migration endpoint to fix database schema issues
// WARNING: This is destructive - only call once!
router.post("/fix-user-schema", async (req, res) => {
  let conn;
  try {
    conn = await db.getConnection();
    
    console.log("🔧 Starting user table schema migration...");

    // Step 1: Delete admin records with id = 0
    console.log("Step 1: Deleting admin records with id_NIM_NIP = 0...");
    const [delResult] = await conn.query(
      "DELETE FROM `user` WHERE id_NIM_NIP = 0 OR id_NIM_NIP = '0'"
    );
    console.log(`✅ Deleted ${delResult.affectedRows} admin records`);

    // Step 2: Drop the PRIMARY KEY constraint and modify column type
    console.log("Step 2: Modifying id_NIM_NIP column type to VARCHAR...");
    try {
      await conn.query("ALTER TABLE `user` DROP PRIMARY KEY");
      console.log("✅ Dropped old PRIMARY KEY");
    } catch (e) {
      console.log("⚠️ PRIMARY KEY already dropped or doesn't exist");
    }

    // Step 3: Modify the column to VARCHAR
    await conn.query(
      "ALTER TABLE `user` MODIFY COLUMN `id_NIM_NIP` VARCHAR(50) NOT NULL"
    );
    console.log("✅ Modified id_NIM_NIP to VARCHAR(50)");

    // Step 4: Add PRIMARY KEY back
    await conn.query("ALTER TABLE `user` ADD PRIMARY KEY (`id_NIM_NIP`)");
    console.log("✅ Added PRIMARY KEY on id_NIM_NIP");

    // Step 5: Add a new admin record with proper string ID
    console.log("Step 5: Creating new admin record...");
    try {
      await conn.query(
        `INSERT INTO \`user\` (
          id_NIM_NIP, nama, email_kampus, status_jaminan, 
          status_akun, jenis_pengguna, no_hp_pengguna, password
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        ["ADMIN_SYSTEM", "Admin System", "admin@kampus.com", null, "aktif", "admin", null, "admin"]
      );
      console.log("✅ Created new admin record");
    } catch (e) {
      console.log("⚠️ Admin record creation skipped (might already exist):", e.message);
    }

    res.json({
      success: true,
      message: "✅ Database schema migration completed successfully!",
      details: {
        admin_records_deleted: delResult.affectedRows,
        column_type_changed: "INT -> VARCHAR(50)",
        new_admin_id: "ADMIN_SYSTEM"
      }
    });

  } catch (err) {
    console.error("❌ Migration error:", err.message);
    res.status(500).json({
      success: false,
      message: "Migration failed: " + err.message,
      error: err.sqlMessage || err.message
    });
  } finally {
    if (conn) try { conn.release(); } catch (e) {}
  }
});

module.exports = router;
