// Uses local @xenova/transformers model — no API key required.
let _pipeline: any = null;

async function getEmbeddingPipeline() {
  if (_pipeline) return _pipeline;
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const { pipeline } = await import('@xenova/transformers');
  _pipeline = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
  return _pipeline;
}

export class EmbeddingService {
  async embed(text: string): Promise<number[]> {
    const pipe = await getEmbeddingPipeline();
    const output = await pipe(text, { pooling: 'mean', normalize: true });
    // output.data is a Float32Array
    return Array.from(output.data as Float32Array);
  }
}
