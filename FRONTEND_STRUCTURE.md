# Frontend Folder Structure

## Overview
This document provides a complete map of the MAGNA frontend folder structure, which is a Flutter-based mobile and web application.

---

## Root Directory Files

| File | Purpose |
|------|---------|
| `analysis_options.yaml` | Dart analysis configuration and linting rules |
| `pubspec.yaml` | Flutter project dependencies and configuration |
| `pubspec.lock` | Locked dependency versions |
| `README.md` | Project documentation |
| `magna_coders.iml` | IntelliJ/Android Studio project file |
| `.gitignore` | Git ignore rules |
| `.metadata` | Flutter project metadata |
| `.flutter-plugins-dependencies` | Flutter plugins dependency tracking |
| `flutter 1.md` | Flutter documentation/notes (1) |
| `flutter 2.md` | Flutter documentation/notes (2) |

---

## Root Directories

### 1. `/lib` - Main Application Code
The heart of the Flutter application containing all Dart source code.

#### Structure:
```
lib/
├── main.dart                              # Application entry point
│
├── app/                                  # Application configuration
│   ├── app.dart                          # Main app widget
│   ├── bootstrap.dart                    # Bootstrap/initialization logic
│   ├── router.dart                       # Route configuration
│   └── theme/                            # App theming
│       ├── colors.dart                   # Color palette definitions
│       ├── spacing.dart                  # Spacing/padding constants
│       ├── typography.dart               # Text styles & fonts
│       └── theme.dart                    # Main theme configuration
│
├── core/                                 # Core functionality & utilities
│   ├── auth/                             # Authentication core logic
│   │   ├── auth_service.dart             # Authentication service
│   │   └── token_storage.dart            # Token persistence
│   ├── network/                          # Network/API clients
│   │   ├── api_client.dart               # HTTP client wrapper
│   │   ├── endpoints.dart                # API endpoint constants
│   │   └── websocket_client.dart         # WebSocket client for real-time
│   ├── storage/                          # Local storage
│   │   └── cache.dart                    # Caching mechanism
│   └── utils/                            # Utility functions
│       ├── logger.dart                   # Logging utility
│       └── validators.dart               # Input validation functions
│
├── features/                             # Feature modules (Clean Architecture)
│   ├── auth/                             # Authentication
│   │   ├── data/                         # Data layer (APIs, repositories)
│   │   ├── domain/                       # Domain layer (entities, usecases)
│   │   └── ui/                           # UI layer
│   │       ├── login_page.dart           # Login screen
│   │       ├── register_page.dart        # Registration screen
│   │       └── oauth_callback_page.dart  # OAuth callback handler
│   │
│   ├── feed/                             # Main feed/timeline
│   │   ├── data/
│   │   │   ├── feed_repository.dart      # Feed data repository
│   │   │   └── post_create_api.dart      # Post creation API
│   │   ├── domain/
│   │   │   ├── post.dart                 # Post entity
│   │   │   ├── post.g.dart               # Generated JSON serialization
│   │   │   └── create_post_request.dart  # Post creation request model
│   │   └── ui/
│   │       ├── feed_page.dart            # Main feed page
│   │       ├── pages/
│   │       │   └── create_post_page.dart # Create post page
│   │       └── widgets/
│   │           ├── feed_post_card.dart   # Post card widget
│   │           ├── feed_filter_bar.dart  # Filter controls
│   │           ├── interaction_bar.dart  # Like/comment/share bar
│   │           ├── post_form_section.dart # Post input form
│   │           └── post_image_picker.dart # Image picker widget
│   │
│   ├── messages/                         # Messaging/chat
│   │   ├── data/
│   │   │   ├── chat_repository.dart      # Chat data repository
│   │   │   ├── dto/                      # Data transfer objects
│   │   │   ├── models/                   # Data models
│   │   │   ├── repositories/             # Repository implementations
│   │   │   └── services/                 # Data services
│   │   ├── domain/
│   │   │   ├── entities/                 # Message entities
│   │   │   ├── message.dart              # Message entity
│   │   │   ├── message.g.dart            # Generated JSON
│   │   │   ├── conversation.dart         # Conversation entity
│   │   │   ├── conversation.g.dart       # Generated JSON
│   │   │   ├── repositories/             # Abstract repositories
│   │   │   └── usecases/                 # Business logic use cases
│   │   └── ui/
│   │       ├── chats_page.dart           # Chats list page
│   │       ├── chat_messages_page.dart   # Individual chat view
│   │       ├── controllers/              # UI controllers/state management
│   │       ├── pages/                    # Additional pages
│   │       └── widgets/                  # Chat UI widgets
│   │
│   ├── jobs/                             # Job listings
│   │   ├── data/                         # Job data layer
│   │   ├── domain/                       # Job entities & logic
│   │   └── ui/                           # Job UI components
│   │
│   ├── job_details/                      # Individual job details
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── projects/                         # Projects listing
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── project_details/                  # Individual project details
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── profile/                          # User profile
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── builders/                         # Builders/creators profiles
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── friends/                          # Social connections
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── notifications/                    # Notifications
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── comments/                         # Comments system
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── post_details/                     # Individual post details
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── contracts/                        # Contract management
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── settings/                         # App settings
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── magna_ai/                         # AI-powered features
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── magna_coin/                       # Cryptocurrency/rewards
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   ├── magna_podcast/                    # Podcast feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── ui/
│   │
│   └── magna_school/                     # Educational content
│       ├── data/
│       ├── domain/
│       └── ui/
│
└── shared/                               # Shared widgets & resources
    ├── icons/                            # Icon assets/library
    └── widgets/                          # Reusable UI components
        ├── app_card.dart                 # Reusable card widget
        ├── app_loader.dart               # Loading indicator
        ├── app_text_field.dart           # Reusable text field
        ├── empty_state.dart              # Empty state display
        └── primary_button.dart           # Primary action button
```

---

### 2. `/assets` - Static Assets
Contains static resources and configuration files.

| File | Purpose |
|------|---------|
| `.env` | Environment variables |

---

### 3. `/web` - Web Configuration
Web-specific configuration and assets for web deployment.

| Item | Purpose |
|------|---------|
| `index.html` | Web entry point HTML |
| `manifest.json` | PWA manifest configuration |
| `favicon.png` | Website favicon |
| `icons/` | Web app icon assets |

---

### 4. `/build` - Build Output
Generated build files and artifacts (auto-generated, not part of source control).

```
build/
├── flutter_assets/         # Flutter asset bundles
│   ├── assets/
│   ├── fonts/
│   ├── packages/
│   └── shaders/
└── web/                    # Web build output
    ├── flutter_bootstrap.js
    ├── flutter_service_worker.js
    ├── flutter.js
    ├── main.dart.js
    ├── index.html
    ├── manifest.json
    ├── canvaskit/
    ├── icons/
    └── assets/
```

---

### 5. `/test` - Test Files
Contains unit and widget tests.

| File | Purpose |
|------|---------|
| `widget_test.dart` | Flutter widget testing |

---

### 6. `/.dart_tool` - Dart Tooling Cache
Auto-generated cache directory for Dart build tools.

---

### 7. `/.idea` - IDE Configuration
IntelliJ/Android Studio IDE configuration and cache.

---

### 8. `/.wrangler` - Wrangler Configuration
Cloudflare Wrangler CLI configuration cache.

---

## Detailed Directory Breakdown

### App Module (`/lib/app`)
Handles application-level configuration and theming.

| File | Purpose |
|------|---------|
| `app.dart` | Root widget that initializes the app |
| `bootstrap.dart` | App bootstrap and initialization logic |
| `router.dart` | Navigation routes configuration |
| `theme/colors.dart` | Application color palette |
| `theme/spacing.dart` | Margin, padding, and spacing constants |
| `theme/typography.dart` | Text styles, font families, and sizes |
| `theme/theme.dart` | Complete theme definition (light/dark modes) |

---

### Core Module (`/lib/core`)
Contains reusable business logic and utilities.

#### Auth (`/lib/core/auth`)
| File | Purpose |
|------|---------|
| `auth_service.dart` | Authentication service (login, logout, register) |
| `token_storage.dart` | Secure token storage and retrieval |

#### Network (`/lib/core/network`)
| File | Purpose |
|------|---------|
| `api_client.dart` | HTTP client with interceptors and error handling |
| `endpoints.dart` | API endpoint constants and base URLs |
| `websocket_client.dart` | WebSocket client for real-time communications |

#### Storage (`/lib/core/storage`)
| File | Purpose |
|------|---------|
| `cache.dart` | Local caching mechanisms and storage |

#### Utils (`/lib/core/utils`)
| File | Purpose |
|------|---------|
| `logger.dart` | Logging utility for debugging |
| `validators.dart` | Input validation functions (email, password, etc.) |

---

### Shared Module (`/lib/shared`)
Reusable widgets and resources shared across features.

#### Widgets (`/lib/shared/widgets`)
| Widget | Purpose |
|--------|---------|
| `app_card.dart` | Reusable card container widget |
| `app_loader.dart` | Loading/spinner indicator component |
| `app_text_field.dart` | Reusable text input field |
| `empty_state.dart` | Empty state display component |
| `primary_button.dart` | Primary action button component |

#### Icons (`/lib/shared/icons`)
Icon assets and icon library definitions for consistent iconography across the app.

---

### Feature Modules - Architecture Pattern

All features follow **Clean Architecture** with three layers:

#### 1. **Data Layer** (`/data`)
Handles data sources and repositories.

**Common files:**
- `repositories/` - Repository implementations
- `models/` - Data models with JSON serialization
- `services/` - API services and data fetching
- `dto/` - Data Transfer Objects
- Example: `feed_repository.dart`, `chat_repository.dart`

#### 2. **Domain Layer** (`/domain`)
Contains business logic, entities, and use cases.

**Common files:**
- `entities/` - Business logic entities
- `repositories/` - Abstract repository interfaces
- `usecases/` - Business logic use cases
- `*.dart` & `*.g.dart` - Entity definitions with JSON serialization
- Example: `post.dart`, `message.dart`, `conversation.dart`

#### 3. **UI Layer** (`/ui`)
Presents data to users and handles user interactions.

**Common structures:**
- `pages/` - Full page widgets
- `widgets/` - Reusable UI components
- `controllers/` - State management controllers
- Example pages: `feed_page.dart`, `chats_page.dart`, `login_page.dart`

---

### Feature Details

#### Authentication (`/features/auth`)
- **UI Pages:** Login, Register, OAuth callback
- **Handles:** User credentials, token management, session
- **Key Files:** `login_page.dart`, `register_page.dart`

#### Feed (`/features/feed`)
- **UI Pages:** Feed display, Create post
- **Widgets:** Post cards, filter bars, interaction bars, image picker
- **Handles:** Post creation, feed retrieval, post interactions
- **Key Components:** `feed_page.dart`, `feed_post_card.dart`, `create_post_page.dart`

#### Messages (`/features/messages`)
- **UI Pages:** Chats list, Individual chat
- **Controllers:** Message state management
- **Entities:** `Message`, `Conversation` with JSON serialization
- **Handles:** Real-time messaging, conversation management
- **Key Components:** `chats_page.dart`, `chat_messages_page.dart`

#### Jobs (`/features/jobs`)
- **Handles:** Job listings, search, filtering
- **Structure:** Data, domain, UI layers

#### Projects (`/features/projects`)
- **Handles:** Project listings and discovery
- **Structure:** Data, domain, UI layers

#### Profile (`/features/profile`)
- **Handles:** User profile display and editing
- **Structure:** Data, domain, UI layers

#### Additional Features
- **Builders**: Creator/builder profile management
- **Friends**: Social connections and friend lists
- **Notifications**: Push notifications and alerts
- **Comments**: Comment system for posts
- **Post Details**: Individual post view and interactions
- **Job/Project Details**: Detailed views of jobs and projects
- **Contracts**: Contract management
- **Settings**: User preferences and app configuration
- **Magna AI**: AI-powered features
- **Magna Coin**: Cryptocurrency and reward system
- **Magna Podcast**: Podcast content
- **Magna School**: Educational content

---

## JSON Serialization Pattern

The app uses `.g.dart` generated files for JSON serialization:
- `post.dart` + `post.g.dart` - Post entity with JSON mapping
- `message.dart` + `message.g.dart` - Message entity with JSON mapping
- `conversation.dart` + `conversation.g.dart` - Conversation entity with JSON mapping

This is typically done using the `json_serializable` package for automatic serialization.

---

## State Management Strategy

The app appears to use:
- **Controllers** in UI layer for state management
- Repository pattern for data abstraction
- Separation of concerns between data, domain, and UI layers

---

## API Integration

- **HTTP Client**: `api_client.dart` for REST API calls
- **WebSocket**: `websocket_client.dart` for real-time features
- **API Endpoints**: Centralized in `endpoints.dart`
- **Data Repositories**: Handle API communication and caching

---

| Feature | Purpose |
|---------|---------|
| **auth** | User authentication and login |
| **builders** | Builders/creators profile management |
| **comments** | Comment system for posts/content |
| **contracts** | Contract management feature |
| **feed** | Main feed/timeline display |
| **friends** | Social connections/friends list |
| **jobs** | Job listings and search |
| **job_details** | Individual job detail view |
| **magna_ai** | AI-powered features |
| **magna_coin** | Digital currency/rewards system |
| **magna_podcast** | Podcast content and playback |
| **magna_school** | Educational content and learning |
| **messages** | Direct messaging and chat |
| **notifications** | Push notifications and alerts |
| **post_details** | Individual post detail view |
| **profile** | User profile management |
| **projects** | Project listings and discovery |
| **project_details** | Individual project detail view |
| **settings** | User preferences and settings |

---

## Technology Stack

- **Framework**: Flutter (Dart)
- **Build System**: Dart/Flutter CLI
- **Web Deployment**: Flutter Web
- **Configuration**: pubspec.yaml
- **IDE**: IntelliJ/Android Studio compatible

---

## Key Observations

1. **Modular Architecture**: The app follows a feature-driven architecture with clear separation of concerns
2. **Cross-Platform**: Supports mobile (iOS/Android) and web platforms
3. **Rich Features**: Includes social, job, AI, crypto, and educational features
4. **Reusable Components**: Shared widgets and icons for consistent UI
5. **Core Services**: Centralized auth, network, and storage in the core module

---

Generated: March 12, 2026
