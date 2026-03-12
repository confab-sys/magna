# Backend Folder Structure

## Overview
This document provides a complete map of the MAGNA backend folder structure. The backend is built using **Cloudflare Workers** with a monorepo architecture using **pnpm workspaces**, featuring multiple applications and shared packages.

---

## Root Directory Files

| File | Purpose |
|------|---------|
| `package.json` | Root workspace configuration with pnpm workspaces |
| `pnpm-workspace.yaml` | pnpm workspace configuration |
| `pnpm-lock.yaml` | Locked dependency versions |
| `wrangler.toml` | Cloudflare Wrangler configuration |

---

## Technology Stack

- **Runtime**: Cloudflare Workers
- **Framework**: Hono (lightweight web framework)
- **Language**: TypeScript
- **Database ORM**: Prisma
- **Package Manager**: pnpm with workspaces
- **Authentication**: bcryptjs, jose (JWT)
- **Build Tool**: Wrangler CLI

---

## Root Scripts

```json
{
  "api:dev": "wrangler dev --package apps/api",           // Start API dev server
  "realtime:dev": "wrangler dev --package apps/realtime", // Start realtime dev server
  "db:generate": "pnpm --filter @magna/db generate",       // Generate Prisma client
  "deploy": "wrangler deploy"                              // Deploy to Cloudflare
}
```

---

## Complete Structure

```
backend/
├── package.json                    # Root workspace config
├── pnpm-workspace.yaml            # pnpm workspace definition
├── pnpm-lock.yaml                 # Dependency lock file
├── wrangler.toml                  # Cloudflare Wrangler config
├── node_modules/                  # Root dependencies
│
├── apps/                          # Applications (Cloudflare Workers)
│   │
│   ├── api/                       # Main API application
│   │   ├── package.json           # API dependencies
│   │   ├── tsconfig.json          # TypeScript config
│   │   ├── wrangler.toml          # Wrangler config
│   │   ├── generate_hash.js       # Hash generation utility
│   │   ├── node_modules/
│   │   ├── .wrangler/             # Wrangler build cache
│   │   ├── migrations/            # Database migrations
│   │   │   ├── 0006_messages_v2.sql
│   │   │   └── 0007_public_groups_discovery.sql
│   │   │
│   │   └── src/                   # API source code
│   │       ├── index.ts           # Worker entry point
│   │       ├── globals.d.ts       # Global type definitions
│   │       ├── types.ts           # API type definitions
│   │       ├── middleware.ts      # Middleware (auth, validation)
│   │       │
│   │       └── routes/            # Route handlers (by feature)
│   │           ├── ai.ts          # AI-related endpoints
│   │           ├── auth.ts        # Authentication endpoints
│   │           ├── chat.ts        # Chat/messaging endpoints
│   │           ├── coins.ts       # Cryptocurrency endpoints
│   │           ├── comments.ts    # Comments endpoints
│   │           ├── contracts.ts   # Contract endpoints
│   │           ├── files.ts       # File upload/download endpoints
│   │           ├── jobs.ts        # Jobs endpoints
│   │           ├── notifications.ts # Notifications endpoints
│   │           ├── podcasts.ts    # Podcast endpoints
│   │           ├── posts.ts       # Posts/feed endpoints
│   │           ├── projects.ts    # Projects endpoints
│   │           ├── school.ts      # Educational content endpoints
│   │           └── users.ts       # User management endpoints
│   │
│   ├── crons/                     # Scheduled tasks/crons
│   │   ├── package.json
│   │   ├── wrangler.toml
│   │   └── src/
│   │       └── (scheduled task handlers)
│   │
│   └── realtime/                  # Real-time WebSocket application
│       ├── package.json
│       ├── wrangler.toml
│       ├── src/
│       │   ├── index.ts           # Worker entry point
│       │   │
│       │   └── objects/           # Durable Objects (state management)
│       │       ├── ChatRoom.ts    # Chat room state management
│       │       └── ContractEscrow.ts # Contract escrow state
│       │
│       └── node_modules/
│
└── packages/                      # Shared packages
    │
    ├── auth/                      # Authentication utilities
    │   ├── package.json
    │   └── (authentication logic)
    │
    ├── db/                        # Database package with Prisma
    │   ├── package.json           # DB package config
    │   ├── index.ts               # DB exports
    │   ├── node_modules/
    │   │
    │   ├── prisma/
    │   │   └── schema.prisma      # Prisma database schema
    │   │
    │   └── migrations/            # Database migrations
    │       └── (migration files)
    │
    ├── shared/                    # Shared utilities & schemas
    │   ├── package.json
    │   ├── node_modules/
    │   │
    │   └── src/
    │       ├── index.ts           # Shared exports
    │       │
    │       └── schemas/           # Shared validation schemas
    │           └── index.ts       # Schema definitions
    │
    └── storage/                   # Storage utilities (S3, uploads)
        ├── package.json
        ├── tsconfig.json
        │
        └── src/
            └── index.ts           # Storage implementation
```

---

## Apps Details

### 1. API App (`/apps/api`)
The main REST API server running on Cloudflare Workers.

**Key Files:**
| File | Purpose |
|------|---------|
| `src/index.ts` | Hono app initialization and middleware setup |
| `src/globals.d.ts` | Global TypeScript declarations for Cloudflare environment |
| `src/types.ts` | Shared TypeScript types and interfaces |
| `src/middleware.ts` | Authentication, validation, error handling middleware |

**Features (Routes):**
| Route | Purpose |
|-------|---------|
| `routes/auth.ts` | Login, register, OAuth, JWT verification |
| `routes/users.ts` | User CRUD, profile management |
| `routes/posts.ts` | Post creation, feed, interactions (likes/comments) |
| `routes/chat.ts` | Messaging API endpoints |
| `routes/jobs.ts` | Job listings, applications, search |
| `routes/projects.ts` | Project CRUD and discovery |
| `routes/comments.ts` | Comment system for posts/projects |
| `routes/notifications.ts` | Notification management and delivery |
| `routes/files.ts` | File upload/download and management |
| `routes/coins.ts` | Cryptocurrency/rewards endpoints |
| `routes/contracts.ts` | Contract management and escrow |
| `routes/podcasts.ts` | Podcast content and metadata |
| `routes/ai.ts` | AI-powered features endpoints |
| `routes/school.ts` | Educational content endpoints |

**Database Migrations:**
```sql
0006_messages_v2.sql        # Messages table schema update
0007_public_groups_discovery.sql # Public groups discovery feature
```

**Dependencies:**
- `@magna/shared` - Shared utilities and validation schemas
- `bcryptjs` - Password hashing
- `hono` - Web framework
- `jose` - JWT handling
- `@cloudflare/workers-types` - Cloudflare types

### 2. Realtime App (`/apps/realtime`)
WebSocket server for real-time features using Cloudflare Durable Objects.

**Key Files:**
| File | Purpose |
|------|---------|
| `src/index.ts` | WebSocket server entry point |
| `src/objects/ChatRoom.ts` | Durable Object for managing chat room state |
| `src/objects/ContractEscrow.ts` | Durable Object for contract escrow state |

**Purpose:**
- Real-time messaging via WebSocket
- Contract state management
- Live notifications
- Real-time chat room synchronization

### 3. Crons App (`/apps/crons`)
Scheduled background tasks using Cloudflare Cron Triggers.

**Purpose:**
- Scheduled email notifications
- Database cleanup
- Analytics updates
- Periodic synchronization tasks
- (Currently empty, can be expanded)

---

## Packages Details

### 1. DB Package (`/packages/db`)
Prisma-based database package managing schema and migrations.

**Files:**
| File | Purpose |
|------|---------|
| `index.ts` | Database client exports |
| `prisma/schema.prisma` | Prisma ORM schema definition |

**Prisma Schema Entities** (typically includes):
- Users
- Posts/Feed
- Comments
- Messages/Conversations
- Jobs
- Projects
- Contracts
- Notifications
- And more...

**Migrations:**
Database schema version history managed through migration files.

**Key Script:**
```bash
pnpm db:generate  # Generate/update Prisma client
```

### 2. Shared Package (`/packages/shared`)
Shared utilities, types, and validation schemas used across apps.

**Structure:**
```
shared/
├── src/
│   ├── index.ts          # Main exports
│   └── schemas/          # Validation schemas
│       └── index.ts      # Zod/validation schemas
```

**Typical Contents:**
- Type definitions
- Zod/validation schemas
- Utility functions
- Constants
- Error handling utilities
- DTO definitions

### 3. Auth Package (`/packages/auth`)
Authentication utilities and logic.

**Typical Contents:**
- JWT token generation/validation
- Password hashing
- Session management
- OAuth integration
- Permission/role checks

### 4. Storage Package (`/packages/storage`)
File storage and upload management utilities.

**File:**
| File | Purpose |
|------|---------|
| `src/index.ts` | Storage implementation (S3, Cloudflare R2, etc.) |

**Typical Features:**
- File upload handling
- File management
- URL generation
- Cleanup utilities

---

## Monorepo Workspace Structure

### Workspace Configuration (`pnpm-workspace.yaml`)
```yaml
packages:
  - 'apps/*'    # All apps are workspaces
  - 'packages/*' # All packages are workspaces
```

### Workspace Dependencies
- Apps can depend on packages using `"@magna/*": "workspace:*"`
- Example: `"@magna/shared": "workspace:*"` in `apps/api/package.json`

### Available Workspaces
- `@magna/api` - Main API application
- `@magna/realtime` - Real-time WebSocket app
- `@magna/crons` - Scheduled tasks
- `@magna/db` - Database package
- `@magna/shared` - Shared utilities
- `@magna/auth` - Authentication package
- `@magna/storage` - Storage utilities

---

## API Architecture

### Request Flow
1. **Request** → Cloudflare Worker
2. **Middleware** (Auth, Validation) → `middleware.ts`
3. **Router** (Hono) → Routes feature detection
4. **Route Handler** → Specific feature route (`/routes/*.ts`)
5. **Business Logic** → Database queries via Prisma
6. **Response** → JSON response

### Authentication Flow
1. User credentials sent to `routes/auth.ts`
2. Password validated with `bcryptjs`
3. JWT token generated with `jose`
4. Token stored in secure cookies/localStorage (client)
5. Token verified on protected routes via middleware

### Real-time Flow
1. **Client WebSocket Connection** → `realtime` app
2. **Durable Object Creation** → ChatRoom or ContractEscrow
3. **State Management** → Persistent state across connections
4. **Broadcasting** → Messages sent to all connected clients
5. **Cleanup** → Connection closed, state persisted

---

## Database Schema Pattern

Prisma schema typically includes:

**Core Entities:**
- `User` - User profiles and auth
- `Post` - Feed posts
- `Comment` - Comments on posts
- `Message/Conversation` - Direct messaging
- `Job` - Job listings
- `Project` - Project listings
- `Contract` - Contract management
- `Notification` - User notifications

**Relationships:**
- Many-to-many (users to friends)
- One-to-many (user to posts, posts to comments)
- Polymorphic relationships (comments on posts/projects)

**Timestamps:**
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp
- `deletedAt` - Soft delete timestamp

---

## Development Setup

### Install Dependencies
```bash
pnpm install
```

### Development Servers
```bash
# Start API dev server on localhost:8787
pnpm api:dev

# Start Realtime dev server
pnpm realtime:dev

# Generate Prisma client
pnpm db:generate
```

### Deployment
```bash
pnpm deploy
```

---

## Key Features Implemented

| Feature | Route | Type |
|---------|-------|------|
| User Authentication | `auth.ts` | REST |
| Post Feed | `posts.ts` | REST |
| Real-time Chat | `chat.ts` + `realtime` | REST + WebSocket |
| Job Management | `jobs.ts` | REST |
| Project Discovery | `projects.ts` | REST |
| Comments System | `comments.ts` | REST |
| Notifications | `notifications.ts` | REST + Real-time |
| File Uploads | `files.ts` | REST |
| Contract Escrow | `contracts.ts` + `realtime` | REST + Durable Objects |
| Cryptocurrency | `coins.ts` | REST |
| Podcasts | `podcasts.ts` | REST |
| AI Features | `ai.ts` | REST |
| Education | `school.ts` | REST |

---

## Deployment Architecture

- **Hosting**: Cloudflare Workers (Serverless Edge Computing)
- **Database**: Likely D1 (Cloudflare SQLite) or external PostgreSQL
- **Real-time**: Durable Objects (Cloudflare stateful computing)
- **Storage**: R2 (Cloudflare object storage) or external S3
- **CDN**: Cloudflare CDN for assets and API responses

---

## Security Considerations

1. **Authentication**: JWT-based with `jose` library
2. **Password Security**: `bcryptjs` with salt rounds
3. **Middleware Protection**: Authentication checks on protected routes
4. **Environment Variables**: Stored in `wrangler.toml` or Cloudflare dashboard
5. **CORS**: Configured in Hono middleware
6. **Rate Limiting**: Can be configured via Cloudflare

---

## Build Process

1. **TypeScript Compilation**: `wrangler` handles compilation
2. **Dependency Resolution**: pnpm resolves workspace packages
3. **Prisma Generation**: `db:generate` creates typed database client
4. **Bundling**: Wrangler bundles for Cloudflare Workers
5. **Deployment**: `wrangler deploy` uploads to Cloudflare

---

Generated: March 12, 2026
