FROM node:20-alpine

WORKDIR /app

# Pin pnpm to v10 — `npm i -g pnpm` (latest) started pulling a build that
# treats uncategorized dependency build scripts as a hard error
# (ERR_PNPM_IGNORED_BUILDS), which broke the deploy.
RUN npm i -g pnpm@10

# pnpm-workspace.yaml carries onlyBuiltDependencies / ignoredBuiltDependencies —
# it MUST be present for the install, or pnpm 10 sees every native build script
# as uncategorized and fails. It was previously only copied with `COPY . .`
# AFTER the install, so the config never applied.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .

RUN pnpm prisma generate
RUN pnpm build

RUN chmod +x /app/docker-entrypoint.dev.sh

EXPOSE 3000
CMD ["/app/docker-entrypoint.dev.sh"]
