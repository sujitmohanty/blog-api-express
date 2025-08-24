# syntax=docker/dockerfile:1

ARG NODE_VERSION=20-alpine
FROM node:${NODE_VERSION} AS base
WORKDIR /app
ENV PORT=3000

############################
# 1) deps stage (needs dev deps to build)
############################
FROM base AS deps
ENV NODE_ENV=development
COPY package*.json ./
RUN npm ci

############################
# 2) build stage (compile + rewrite aliases)
############################
FROM deps AS build
COPY tsconfig*.json ./
COPY src ./src
RUN npx tsc && npx tsc-alias

############################
# 3) runtime stage (production only)
############################
FROM base AS runner
ENV NODE_ENV=production
USER node

# Copy only what's needed to run
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package*.json ./

EXPOSE 3000
CMD ["node", "dist/server.js"]
