# 📖 Blog API (Express.js + TypeScript)

![Node.js](https://img.shields.io/badge/node.js-18.x-green?logo=node.js)
![Express](https://img.shields.io/badge/express.js-5.x-lightgrey?logo=express)
![TypeScript](https://img.shields.io/badge/typescript-5.x-blue?logo=typescript)
![MongoDB](https://img.shields.io/badge/mongoDB-Atlas-green?logo=mongodb)
![Docker](https://img.shields.io/badge/docker-ready-blue?logo=docker)
![JWT](https://img.shields.io/badge/JWT-authentication-red?logo=jsonwebtokens)
![Cloudinary](https://img.shields.io/badge/cloudinary-image%20hosting-yellow?logo=cloudinary)
![License: ISC](https://img.shields.io/badge/License-ISC-blue.svg)

🔗 **Live API**: [https://blog-api-807111925754.europe-west3.run.app/api/v1](https://blog-api-807111925754.europe-west3.run.app)

A **RESTful blog API** built with **Express.js & TypeScript**, featuring **JWT authentication with refresh tokens**, **role-based access control**, **file uploads via Multer + Cloudinary**, and **MongoDB Atlas** for persistence.

The project is containerized with **Docker** and includes production-ready practices like logging, graceful shutdown, and input validation.

---

## ✨ Features

- 🔐 **Authentication & Authorization**
  - Role-based access control (User/Admin)
  - Access & Refresh token system (JWT)
  - Secure cookie handling

- 📝 **Blog Management**
  - CRUD for blog posts
  - Banner image uploads (Multer + Cloudinary)
  - Slug-based blog retrieval

- 👤 **User Management**
  - CRUD for users
  - Profile updates & self-deletion

- ⚡ **Production-Ready Enhancements**
  - Input validation (express-validator)
  - Security (Helmet, CORS, Rate-limiting)
  - Logging (Winston)
  - Graceful shutdown handler
  - Dockerized setup

---

## 🛠 Tech Stack

- **Backend**: Express.js (TypeScript)
- **Database**: MongoDB Atlas
- **Authentication**: JWT (Access + Refresh tokens)
- **File Uploads**: Multer + Cloudinary
- **Security**: Helmet, CORS, express-rate-limit
- **Logging**: Winston
- **Containerization**: Docker
- **Validation**: express-validator
- **Other Utilities**: dotenv, compression

---

## 📂 Project Structure

```
blog-api-express/
├── src/                # Source code (controllers, models, routes, middleware)
├── dist/               # Compiled JS output
├── .env.example        # Example environment variables
├── Dockerfile          # Docker build file
├── package.json        # Dependencies & scripts
└── tsconfig.json       # TypeScript config
```

---

## ⚙️ Environment Variables

Copy `.env.example` → `.env` and fill in your values:

```env
PORT=3000
MONGO_URI=<your_mongodb_atlas_connection_string>
JWT_ACCESS_SECRET=<your_access_token_secret>
JWT_REFRESH_SECRET=<your_refresh_token_secret>
CLOUDINARY_CLOUD_NAME=<your_cloudinary_name>
CLOUDINARY_API_KEY=<your_cloudinary_api_key>
CLOUDINARY_API_SECRET=<your_cloudinary_api_secret>
```

---

## 🚀 Installation & Setup

### Local Development

```bash
# Clone repo
git clone https://github.com/yourusername/blog-api-express.git
cd blog-api-express

# Install dependencies
npm install

# Run dev server with nodemon
npm run dev

# Build for production
npm run build

# Run compiled server
npm start
```

### Using Docker

```bash
# Build image
docker build -t blog-api .

# Run container
docker run -p 4000:8080 --env-file .env blog-api
```

---

## 📡 API Endpoints

Full Postman Collection: [🔗 View on Postman](https://www.postman.com/sujit-mohanty/workspace/blog-api-express-js/collection/8471258-cc955262-dc8c-4d93-8339-decc31c1097d?action=share&source=collection_link&creator=8471258)

### Auth

| Method | Endpoint              | Description       |
| ------ | --------------------- | ----------------- |
| POST   | `/auth/register`      | Register new user |
| POST   | `/auth/login`         | Login user        |
| POST   | `/auth/refresh-token` | Refresh JWT token |
| POST   | `/auth/logout`        | Logout user       |

### Users

| Method | Endpoint         | Description               |
| ------ | ---------------- | ------------------------- |
| GET    | `/users/current` | Get logged-in user        |
| PUT    | `/users/current` | Update profile            |
| DELETE | `/users/current` | Delete own account        |
| GET    | `/users/`        | Get all users (admin)     |
| GET    | `/users/:id`     | Get user by ID (admin)    |
| DELETE | `/users/:id`     | Delete user by ID (admin) |

### Blog Posts

| Method | Endpoint              | Description        |
| ------ | --------------------- | ------------------ |
| POST   | `/blogs`              | Create blog post   |
| PUT    | `/blogs/:id`          | Update blog post   |
| DELETE | `/blogs/:id`          | Delete blog post   |
| GET    | `/blogs`              | Get all blog posts |
| GET    | `/blogs/user/:userId` | Get posts by user  |
| GET    | `/blogs/:slug`        | Get post by slug   |

---

## 📸 Screenshots

### Example: Postman Register Endpoint

![Register API Response](https://i.ibb.co/ccv5NvTF/Screenshot-2025-08-24-181246.png)

---

## 🐳 Docker + DevOps Notes

- Image is built from `Dockerfile` with production settings
- Environment variables injected via `--env-file`
- Port mapping example: `-p 4000:3000`
- Can be extended with `docker-compose` for multi-service setup

---

## 📖 Logging

- Logs are handled via **Winston**
- Different transports for console and file
- JSON structured logging (ready for production monitoring tools)

---

## 🔐 Security & Reliability

- Secrets never hardcoded or committed to VCS

- Role-based access for service accounts (principle of least privilege)

- Health checks via /health endpoint for monitoring

- Graceful shutdown handlers for clean DB disconnection during container termination

---

## 🚀 DevOps & Deployment

This project demonstrates modern DevOps workflows in addition to backend API development:

### 🐳 Containerization with Docker

- Multi-stage **Dockerfile** for optimized builds:
  - Stage 1: Install dependencies & compile TypeScript → `dist/`
  - Stage 2: Copy production artifacts, install only production dependencies, run as non-root user
- `.dockerignore` configured to keep images slim
- Works both locally (`docker run --env-file .env -p 4000:8080 blog-api`) and in production (`NODE_ENV=production`)

### 🔄 Continuous Integration (GitHub Actions → GHCR)

- GitHub Actions workflow builds Docker images on pushes
- Images are published to **GitHub Container Registry (GHCR)**
- Tagged with commit SHA and `latest` for traceability

### ☁️ Continuous Deployment to Google Cloud Run

- Cloud Run pulls images from GHCR for deployment
- Environment configuration:
  - Sensitive values (`JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET`, `MONGO_URI`, `CLOUDINARY_URL`) stored in **Google Secret Manager**
  - Non-sensitive config (`NODE_ENV`, `LOG_LEVEL`, token expiry times) injected via Cloud Run environment variables
- Cloud Run handles:
  - Auto-scaling based on traffic
  - HTTPS endpoint & traffic splitting between revisions
  - Zero-downtime deployments

---

### ✅ Summary

This project is fully containerized, automatically built via GitHub Actions, published to GHCR, and deployed to Google Cloud Run with secrets managed securely through Secret Manager.  
It demonstrates an **end-to-end CI/CD pipeline** from source code → container → cloud deployment.

---

## 📜 License

[ISC](./LICENSE) © Sujit Mohanty
