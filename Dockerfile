# syntax=docker/dockerfile:1
ARG NODE_VERSION=20-slim

# ---------- deps (install all deps incl. dev for build) ----------
FROM node:${NODE_VERSION} AS deps
WORKDIR /app

# Native module toolchain (e.g., for bcrypt). Only in build stage.
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ ca-certificates && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

# ---------- build (compile TS -> dist and fix path aliases) ----------
FROM node:${NODE_VERSION} AS build
WORKDIR /app

# Bring node_modules from deps to speed up builds
COPY --from=deps /app/node_modules ./node_modules
# Copy sources
COPY . .

# Compile TypeScript and fix path aliases (expects scripts below)
# e.g. "build": "tsc && tsc-alias"
RUN npm run build

# ---------- runner (tiny, prod-only deps) ----------
FROM node:${NODE_VERSION} AS runner
WORKDIR /app

ENV NODE_ENV=production

# Install only production deps
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# Bring compiled app and any runtime assets
COPY --from=build /app/dist ./dist
# If you have runtime files (e.g., openapi.yaml, public/, views/), copy them:
# COPY --from=build /app/openapi.yaml ./openapi.yaml
# COPY --from=build /app/public ./public

# Cloud Run sets PORT; default to 8080
ENV PORT=8080
EXPOSE 8080

# Run as non-root
USER node

CMD ["node", "dist/server.js"]
