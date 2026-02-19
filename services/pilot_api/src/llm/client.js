async function postJson(url, headers, body) {
  const res = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json", ...headers },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`llm_http_${res.status}: ${text}`);
  return text ? JSON.parse(text) : {};
}

async function chatOllama({ baseUrl, model, messages }) {
  const url = `${baseUrl.replace(/\/$/, "")}/api/chat`;
  const data = await postJson(url, {}, { model, messages, stream: false });
  // ollama returns { message: { role, content } }
  return data?.message?.content ?? "";
}

// OpenAI Responses API (recommended) 
async function chatOpenAI({ apiKey, model, messages }) {
  const url = "https://api.openai.com/v1/responses";
  const data = await postJson(
    url,
    { Authorization: `Bearer ${apiKey}` },
    {
      model,
      input: messages.map((m) => ({
        role: m.role,
        content: [{ type: "input_text", text: m.content }],
      })),
    }
  );

  // best-effort: pull final text
  const out = data?.output ?? [];
  for (const item of out) {
    const content = item?.content ?? [];
    for (const c of content) {
      if (c?.type === "output_text" && typeof c.text === "string") return c.text;
    }
  }
  return "";
}

// Anthropic Messages API example headers/body  [oai_citation:0‡Claude API Docs](https://docs.anthropic.com/de/api/messages-examples?utm_source=chatgpt.com)
async function chatAnthropic({ apiKey, model, messages }) {
  const url = "https://api.anthropic.com/v1/messages";
  const data = await postJson(
    url,
    {
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    {
      model,
      max_tokens: 800,
      messages: messages
        .filter((m) => m.role !== "system")
        .map((m) => ({ role: m.role, content: m.content })),
      system: messages
        .filter((m) => m.role === "system")
        .map((m) => m.content)
        .join("\n"),
    }
  );

  // content is array of blocks; pick text
  const blocks = data?.content ?? [];
  const textBlock = blocks.find((b) => b?.type === "text");
  return textBlock?.text ?? "";
}

// Gemini: easiest is AI Studio key (Generative Language API)  [oai_citation:1‡Google AI for Developers](https://ai.google.dev/api/rest/generativelanguage/models/get?utm_source=chatgpt.com)
async function chatGemini({ apiKey, model, messages }) {
  const base = "https://generativelanguage.googleapis.com";
  const url = `${base}/v1beta/models/${model}:generateContent?key=${apiKey}`;

  const system = messages.filter((m) => m.role === "system").map((m) => m.content).join("\n");
  const convo = messages.filter((m) => m.role !== "system");

  const contents = [];
  if (system.trim()) {
    contents.push({ role: "user", parts: [{ text: system }] });
  }
  for (const m of convo) {
    // gemini roles are "user" and "model"
    contents.push({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }],
    });
  }

  const data = await postJson(url, {}, { contents });
  return data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
}

async function llmChat({ messages }) {
  const provider = (process.env.LLM_PROVIDER || "ollama").toLowerCase();

  if (provider === "openai") {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) throw new Error("missing_OPENAI_API_KEY");
    const model = process.env.OPENAI_MODEL || "gpt-4.1-mini";
    return chatOpenAI({ apiKey, model, messages });
  }

  if (provider === "anthropic") {
    const apiKey = process.env.ANTHROPIC_API_KEY;
    if (!apiKey) throw new Error("missing_ANTHROPIC_API_KEY");
    const model = process.env.ANTHROPIC_MODEL || "claude-3-5-sonnet-latest";
    return chatAnthropic({ apiKey, model, messages });
  }

  if (provider === "gemini") {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) throw new Error("missing_GEMINI_API_KEY");
    const model = process.env.GEMINI_MODEL || "gemini-1.5-flash";
    return chatGemini({ apiKey, model, messages });
  }

  // default: ollama
  const baseUrl = process.env.OLLAMA_URL || "http://host.docker.internal:11434";
  const model = process.env.OLLAMA_MODEL || "phi3:latest";
  return chatOllama({ baseUrl, model, messages });
}

module.exports = { llmChat };
