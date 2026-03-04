# --- deps (install once, keep pnpm workspace layout) ---
FROM node:20-alpine AS deps
WORKDIR /app
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY . .

RUN pnpm config set node-linker hoisted
ENV CI=true
ENV NODE_ENV=development
ENV PATH=/app/node_modules/.bin:/app/services/api/node_modules/.bin:$PATH
RUN pnpm config set confirmModulesPurge false
RUN pnpm -w install --frozen-lockfile --prod=false --reporter=append-only

# --- build (reuse exact installed workspace) ---
FROM node:20-alpine AS build
WORKDIR /app
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY --from=deps /app /app

ENV DATABASE_URL="postgresql://user:pass@localhost:5432/db?schema=public"
RUN ls -la ./node_modules/.bin | grep -E "prisma|next" || true
RUN ls -la /app/node_modules/.bin | grep prisma || true
RUN /app/node_modules/.bin/prisma generate --schema=services/api/prisma/schema.prisma
RUN pnpm -w --filter @... run build

# --- runtime ---
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY --from=build /app/services/api/dist /app/dist
COPY --from=build /app/services/api/package.json /app/package.json
COPY --from=build /app/services/api/prisma /app/prisma
COPY --from=build /app/node_modules /app/node_modules

EXPOSE 3000
CMD ["sh","-lc","pnpm -s prisma migrate deploy || true; node dist/main.js"]
