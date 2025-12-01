const LogAktivitas = require('../models/LogAktivitas');

/**
 * Wrapper helper to create a log entry using req context.
 * - req.adminId and req.clientInfo are used if available
 * - non-blocking: logs errors to console but does not throw
 */
function logActivity(req, jenis, deskripsi) {
  if (!req) return;
  const payload = {
    id_pegawai: req.adminId || null,
    waktu_aktivitas: new Date(),
    jenis_aktivitas: jenis,
    deskripsi_aktivitas: deskripsi + (req.adminId ? '' : ` (anon from ${req.clientInfo?.ip || 'unknown'})`),
  };

  try {
    LogAktivitas.create(payload, (err) => {
      if (err) console.error('Gagal catat log aktivitas:', err);
    });
  } catch (e) {
    console.error('Error saat logActivity:', e);
  }
}

module.exports = logActivity;
