# Magna Coders Flutter App — Repo Bootstrap Prompt (Give This to Your AI)

You are my **senior Flutter architect + repo bootstrapper**. Your task is to generate a **clean Flutter project from scratch** with a professional architecture, using the exact structure and routing plan below. You must output a step-by-step implementation plan **and** the exact file/folder skeleton.

## Mission
Create a new Flutter app repo for **Magna Coders** with:
- Clean folder architecture (feature-based)
- Bottom-tab navigation (5 tabs)
- go_router routing with protected routes (auth gate)
- Dio API client with interceptors
- Secure token storage
- WebSocket client scaffold
- Centralized API endpoints file
- Environment variables support
- Premium, consistent UI foundation (theme tokens + shared widgets)

We are NOT migrating Next.js code. We are rebuilding the Flutter client using the same product modules and API contracts.

---

## Required Project Structure (MUST match exactly)

Create these folders and placeholder files:
lib/
app/
app.dart // MaterialApp, theme, router
router.dart // go_router routes
bootstrap.dart // startup checks, env, auth restore
theme/
theme.dart
colors.dart
typography.dart
spacing.dart

core/
network/
api_client.dart // Dio client + interceptors
endpoints.dart // central endpoint strings
websocket_client.dart
auth/
auth_service.dart // token lifecycle
token_storage.dart // flutter_secure_storage
storage/
cache.dart // optional (Hive/Isar)
utils/
logger.dart
validators.dart

features/
auth/
data/ // dtos, api
domain/ // models
ui/ // pages, widgets
feed/
profile/
projects/
jobs/
builders/
friends/
messages/
notifications/
magna_ai/
magna_coin/
magna_school/
magna_podcast/
contracts/
settings/

shared/
widgets/ // buttons, cards, modals, inputs, loaders
icons/
constants/