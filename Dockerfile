# syntax=docker/dockerfile:1
ARG NODE_VERSION=20-slim

# ---------- deps (install all deps incl. dev for build) ----------
FROM node:${NODE_VERSION} AS deps
WORKDIR /app

# If you have native modules (e.g., bcrypt), build tools help during npm ci
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 make g++ ca-certificates && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

# ---------- build (compile TS -> dist and fix path aliases) ----------
FROM node:${NODE_VERSION} AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# IMPORTANT: your package.json should have:  "build": "tsc && tsc-alias"
# If you don't use path aliases, "tsc" alone is fine.
RUN npm run build

# sanity: confirm build output
RUN node -e "const fs=require('fs'); console.log('Built files in dist/:', fs.readdirSync('./dist',{withFileTypes:true}).map(d=>d.name))"

# ---------- runtime (only prod deps + dist) ----------
FROM node:${NODE_VERSION} AS runner
WORKDIR /app
ENV NODE_ENV=production PORT=3000

# Install only production deps
COPY package*.json ./
RUN npm ci --omit=dev

# Bring compiled code
COPY --from=build /app/dist ./dist

# Optional healthcheck (expects GET /api/v1/health = 200)
# HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
#   CMD node -e "require('http').get('http://127.0.0.1:'+process.env.PORT+'/api/v1/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

# Run as non-root (built-in 'node' user)
USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
