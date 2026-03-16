# flashmind-mobile

FlashMind Mobile is a simple fullstack MVP for generating study flashcards from uploaded documents. The user signs in with Google or Apple, uploads a `.pdf`, `.docx`, or `.pptx` file, chooses a flashcard mode, and gets a deck back quickly without permanently storing the original document.

## Stack

- Frontend: Flutter, Dart, Riverpod, go_router, dio, flutter_secure_storage, file_picker
- Mobile subscriptions: RevenueCat
- Backend: Java 21, Spring Boot, Spring Security, Spring Data JPA, PostgreSQL, Maven
- Document extraction: Apache PDFBox, Apache POI
- Auth: Google and Apple social login entrypoint with app JWT sessions
- AI integration: `FlashcardGenerationPort` with OpenAI adapter placeholder and local mock adapter

## Repository Structure

```text
flashmind-mobile/
  README.md
  .gitignore
  docker-compose.yml
  .env.example
  frontend/
  backend/
```

## Product Constraints

- Uploaded files are processed temporarily and are not stored permanently.
- Supported file types: `.pdf`, `.docx`, `.pptx`
- Unsupported: scanned PDFs, OCR, images, `.doc`, `.ppt`
- Maximum file size: 10 MB
- Maximum flashcards per generation: 20
- Text extraction is truncated before AI generation to keep requests fast

## Backend Setup

1. Start PostgreSQL:

```bash
docker compose up -d
```
2. Review backend config files:

- `backend/src/main/resources/application.yml`
- `backend/src/main/resources/application-local.yml`
- `backend/src/main/resources/application-example.yml`

3. Run the backend with the local profile:

```bash
cd backend
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

The local profile is already configured for Docker PostgreSQL at `127.0.0.1:5433`, enables dev-login bypass, and uses the mock flashcard generator until you wire a real OpenAI key/provider.

## Frontend Setup

1. Review `frontend/pubspec.yaml`.
2. Run:

```bash
cd frontend
flutter pub get
flutter run
```

Local defaults:

- Android emulator: `http://10.0.2.2:8080`
- iOS simulator / desktop / web: `http://localhost:8080`
- Frontend mocks are disabled by default in local code now

If you want to override the backend URL manually:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Important Flutter Note

The sandbox used to generate this repository could not execute the local Flutter SDK because the SDK directory was access-restricted. The Flutter app source, `pubspec.yaml`, routing, theme, and feature structure are included, but if native platform folders are missing in your local environment, run this once inside `frontend/`:

```bash
flutter create . --platforms=android,ios
```

That will materialize the standard Flutter platform shells around the existing Dart source.

## Social Login Flow

- Frontend gets a provider ID token from Google or Apple.
- Frontend sends `provider` and `idToken` to `POST /api/auth/social-login`.
- Backend validates or prepares to validate the provider token.
- Backend creates or updates the local user and returns an app JWT.
- Frontend stores the app JWT in secure storage and uses it for future API calls.

## Manual Setup Still Required

- `OPENAI_API_KEY`
- `JWT_SECRET`
- `REVENUECAT_API_KEY`
- `WEBHOOK_SECRET`
- `PRODUCT_ID`
- PostgreSQL credentials
- Google OAuth client IDs and Android/iOS configuration
- Apple Sign In capability, service identifiers, and key material
- RevenueCat project, entitlement, and store product configuration
- Real production-grade Google and Apple ID token verification

The project already contains placeholders, config bindings, and TODO comments where these values need to be wired.

## Dev Login Bypass

For local development you can skip social login end to end.

Backend:

- Set `flashmind.auth.allow-dev-login-bypass=true`
- The local profile already enables it in `backend/src/main/resources/application-local.yml`
- `POST /api/auth/dev-login` will issue an app JWT for the configured demo user

Frontend:

- The local app config already enables `Entrar sin login`
- If you also want to work without the backend running, add `--dart-define=USE_FRONTEND_MOCKS=true`
- In mock mode, auth, deck listing, deck generation, and study data all run locally in memory

The bypass is intended for local development only and is disabled by default in the base config.

## Running PostgreSQL

```bash
docker compose up -d
docker compose logs -f postgres
```

## Supported Files and Limits

- `.pdf`, `.docx`, `.pptx`
- max file size: 10 MB
- max generated cards: 20
- extracted text length is truncated in the backend
- PDF page and PPTX slide counts are bounded in config

## API Overview

- `POST /api/auth/social-login`
- `GET /api/auth/me`
- `GET /api/me`
- `GET /api/me/generation-access`
- `GET /api/decks`
- `GET /api/decks/{id}`
- `GET /api/decks/{id}/flashcards`
- `POST /api/decks/generate`
- `POST /api/subscriptions/revenuecat/webhook`

## Development Seed Data

The local profile seeds:

- 1 demo user
- 2 demo decks
- sample flashcards

## Security Notes

- Only app JWT auth is implemented for the MVP.
- No password login is included.
- Uploaded documents are never persisted to the database.
