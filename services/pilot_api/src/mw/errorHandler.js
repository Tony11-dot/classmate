function errorHandler(err, _req, res, _next) {
  const status = err.status || 500;
  const code = err.code || "internal_error";
  const message =
    typeof err.message === "string" && err.message.length ? err.message : "Unexpected error";

  res.status(status).json({ error: code, message });
}

module.exports = { errorHandler };
