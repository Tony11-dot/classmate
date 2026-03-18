type CounterMap = Record<string, number>;

class InMemoryMetrics {
  private counters: CounterMap = {};
  private timings: Record<string, number[]> = {};

  inc(name: string, value = 1) {
    this.counters[name] = (this.counters[name] || 0) + value;
  }

  observe(name: string, ms: number) {
    if (!this.timings[name]) this.timings[name] = [];
    this.timings[name].push(ms);
  }

  snapshot() {
    return {
      counters: this.counters,
      timings: Object.fromEntries(
        Object.entries(this.timings).map(([k, arr]) => [
          k,
          {
            count: arr.length,
            avg: arr.length ? arr.reduce((a, b) => a + b, 0) / arr.length : 0,
            p95: arr.length
              ? [...arr].sort((a, b) => a - b)[Math.max(0, Math.floor(arr.length * 0.95) - 1)]
              : 0,
          },
        ]),
      ),
    };
  }
}

export const metrics = new InMemoryMetrics();
