const express = require("express");
const fs = require("fs");
const path = require("path");

const SYSTEM_PROMPT = fs.readFileSync(path.join(__dirname, "tutor", "systemPrompt.txt"), "utf-8");
const { z } = require("zod");
const { validate } = require("./mw/validate");
const { asyncWrap } = require("./mw/asyncWrap");
const { HttpError } = require("./mw/httpError");

const { llmChat } = require("./llm/client");
function buildTutorRouter({ auth }) {
  const router = express.Router();

  const Body = z.object({
    messages: z
      .array(
        z.object({
          role: z.enum(["system", "user", "assistant"]),
          content: z.string().min(1),
        })
      )
      .min(1),
  });

  router.post(
    "/chat",
    auth,
    validate({ body: Body }),
    asyncWrap(async (req, res) => {
      const founderName = process.env.FOUNDER_NAME || "Tony Aboud";
      const founderAbout =
        process.env.FOUNDER_ABOUT ||
        "Tony Aboud is the creator of ClassMate. He’s a CS/CE student in Israel and is into physics, math, AI, and building real products.";
            const reply = await llmChat({ messages: [{ role: "system", content: SYSTEM_PROMPT }, ...req.body.messages] });

if (!reply || !reply.trim())
        throw new HttpError(502, "llm_empty", "LLM returned empty reply");

      res.json({ reply });
    })
  );

  return router;
}

module.exports = { buildTutorRouter };
