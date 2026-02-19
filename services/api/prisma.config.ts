import dotenv from 'dotenv';
import { defineConfig } from 'prisma/config';

// Ensure Prisma CLI gets the same env vars it used to get from .env
dotenv.config({ path: process.env.PRISMA_DOTENV_PATH || '.env' });

export default defineConfig({
  schema: 'prisma/schema.prisma',
});
