FROM node:20-alpine AS deps
WORKDIR /app
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY . .

RUN pnpm config set node-linker hoisted
ENV CI=true
ENV NODE_ENV=development
ENV PATH=/app/node_modules/.bin:/app/apps/admin-web/node_modules/.bin:$PATH
RUN pnpm config set confirmModulesPurge false
RUN pnpm -w install --frozen-lockfile --prod=false --reporter=append-only

FROM node:20-alpine AS build
WORKDIR /app
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY --from=deps /app /app

RUN rm -f apps/admin-web/.next/lock || true
RUN ls -la /app/node_modules/.bin | grep -E "next|react|node" || true
RUN ls -la /app/apps/admin-web/node_modules/.bin || true
RUN cd /app/apps/admin-web && node ../../node_modules/next/dist/bin/next build

FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0
RUN corepack enable && corepack prepare pnpm@10.26.2 --activate

COPY --from=build /app/apps/admin-web/.next /app/.next
COPY --from=build /app/apps/admin-web/public /app/public
COPY --from=build /app/apps/admin-web/package.json /app/package.json
COPY --from=build /app/node_modules /app/node_modules

EXPOSE 3001
CMD ["sh","-lc","pnpm -s start -p 3001"]
