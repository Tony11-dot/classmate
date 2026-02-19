import path from 'node:path';
import fs from 'node:fs';
import dotenv from 'dotenv';

if (process.env.NODE_ENV === 'test') {
  const p = path.resolve(__dirname, '../../.env.test');
  if (fs.existsSync(p)) dotenv.config({ path: p });
}
