async function ollamaChat({ baseUrl, model, messages }) {
  const url =
    (baseUrl || "http://host.docker.internal:11434").replace(/\/$/, "") + "/api/chat";

  const r = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ model: model || "llama3.1", messages, stream: false }),
  });

  if (!r.ok) {
    const t = await r.text().catch(() => "");
    throw new Error(`ollama_error_${r.status}: ${t}`);
  }

  const data = await r.json();
  return data?.message?.content || "";
}

module.exports = { ollamaChat };
