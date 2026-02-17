const { ZodError } = require("zod");
const { HttpError } = require("./httpError");

function validate({ query, body, params } = {}) {
  return (req, _res, next) => {
    try {
      if (query) req.query = query.parse(req.query);
      if (body) req.body = body.parse(req.body);
      if (params) req.params = params.parse(req.params);
      next();
    } catch (e) {
      if (e instanceof ZodError) {
        return next(new HttpError(400, "validation_error", JSON.stringify(e.issues)));
      }
      next(e);
    }
  };
}

module.exports = { validate };
