# syntax=docker/dockerfile:1

ARG NODE_VERSION=20-alpine
FROM node:${NODE_VERSION} AS base
WORKDIR /app
ENV PORT=3000

############################
# 1. Install deps (incl dev)
############################
FROM base AS deps
# Temporarily force NODE_ENV=development so devDependencies are installed
ENV NODE_ENV=development
COPY package*.json ./
RUN npm ci

############################
# 2. Build TS -> dist
############################
FROM deps AS build
COPY tsconfig*.json ./
COPY src ./src
RUN npx tsc

############################
# 3. Runtime (production only)
############################
FROM base AS runner
ENV NODE_ENV=production
USER node

# Copy production-only node_modules
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package*.json ./

EXPOSE 3000
CMD ["node", "-r", "tsconfig-paths/register", "dist/server.js"]
