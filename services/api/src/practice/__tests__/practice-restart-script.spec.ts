import { readFileSync } from 'node:fs';
import { join } from 'node:path';

describe('practice clean restart script', () => {
  it('kills existing listener before starting api on 3001', () => {
    const s = readFileSync(
      join(process.cwd(), 'scripts', 'restart-api-clean.sh'),
      'utf8',
    );

    expect(s).toContain('lsof -tiTCP:${PORT} -sTCP:LISTEN');
    expect(s).toContain('kill -9');
    expect(s).toContain('rm -rf dist');
    expect(s).toContain('start:dev');
    expect(s).toContain('/health');
  });
});
