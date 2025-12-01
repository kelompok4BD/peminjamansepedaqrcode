/**
 * Simple middleware that extracts admin id and client info from request
 * - Sets `req.adminId` from header `x-admin-id` or body `id_pegawai`
 * - Sets `req.clientInfo` with `ip` and `userAgent`
 */
module.exports = (req, res, next) => {
  try {
    const headerAdmin = req.headers['x-admin-id'] || req.headers['X-Admin-Id'];
    req.adminId = headerAdmin || req.body?.id_pegawai || null;
    req.clientInfo = {
      ip: req.ip || req.connection?.remoteAddress || null,
      userAgent: req.get ? req.get('User-Agent') : (req.headers['user-agent'] || null),
    };
  } catch (e) {
    req.adminId = null;
    req.clientInfo = { ip: null, userAgent: null };
  }
  next();
};
