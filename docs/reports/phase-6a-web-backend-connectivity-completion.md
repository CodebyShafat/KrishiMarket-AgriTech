# Phase 6A: Web ↔ Backend Connectivity Completion Report

## Root Cause Analysis
The Flutter Web frontend was experiencing a "Network Error" when attempting to communicate with the FastAPI backend. This was caused by two compounding issues:
1. **Incorrect Loopback IP on Web:** The `ApiClient` defaulted the `API_BASE_URL` to `http://10.0.2.2:8000/api/v1`. While `10.0.2.2` correctly resolves to the host machine from inside an Android emulator, Flutter Web runs directly on the host's Chrome browser, meaning `10.0.2.2` resulted in a dead-end connection timeout.
2. **Missing CORS Configuration:** Even if the IP were correct (`127.0.0.1`), the FastAPI backend lacked Cross-Origin Resource Sharing (CORS) middleware. Chrome strictly enforces CORS policies for Web apps running on localhost (e.g. `http://localhost:52410`), which led to the browser blocking the request before it could be processed.

## Exact Networking Behavior by Platform (Implemented)
- **Web (`kIsWeb == true`):** Defaults to `http://127.0.0.1:8000/api/v1`.
- **Mobile/Emulator (`kIsWeb == false`):** Defaults to `http://10.0.2.2:8000/api/v1`.
- **Explicit Override:** If the developer passes `--dart-define=API_BASE_URL=https://api.krishimarket.com/v1`, this takes absolute precedence over all platform defaults.

## CORS Configuration
FastAPI was updated with the following secure local-development CORS policy using a Regex matcher rather than a blanket wildcard (`*`):
- **Allowed Origins:** `https?://(localhost|127\.0\.0\.1)(:[0-9]+)?` (Matches `localhost` and `127.0.0.1` on any port, supporting Flutter Web's randomized local ports).
- **Allowed Methods:** `*` (GET, POST, PUT, DELETE, OPTIONS, etc.)
- **Allowed Headers:** `*` (Includes `Authorization`, `Content-Type`, etc.)
- **Credentials:** Allowed.

## Files Changed
1. **`lib/core/network/api_client.dart`**:
   - Imported `package:flutter/foundation.dart`.
   - Updated the `ApiClient` constructor to dynamically evaluate the default `baseUrl` using a private static method that checks `kIsWeb`.
2. **`backend/app/main.py`**:
   - Imported `CORSMiddleware` from `fastapi.middleware.cors`.
   - Injected the middleware into the `FastAPI` app initialization.

## Tests Executed & Results
- **Frontend Linter:** `flutter analyze` — PASS (0 errors)
- **Frontend Unit/Widget Tests:** `flutter test` — PASS (55/55 passed)
- **Backend Tests:** `venv\Scripts\pytest` — PASS (6/6 passed)
- **Integration Validation:** The auth flow (OTP request -> verify -> me endpoint) handles `Authorization` header injection correctly and is successfully verified by the FastAPI dependency pipeline. 

## How to Run the Application

**1. Start the FastAPI Backend:**
```powershell
cd backend
venv\Scripts\activate
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```
*Note: The backend should print `Application startup complete.`*

**2. Start Flutter Web:**
```powershell
flutter run -d chrome --dart-define=USE_API_BACKEND=true
```
*Note: You no longer need to manually pass `--dart-define=API_BASE_URL=...` for local testing.*

## Rollback Instructions
To rollback these changes, remove the `CORSMiddleware` block in `backend/app/main.py` and revert the `ApiClient` constructor in `lib/core/network/api_client.dart` back to the static string environment default.
