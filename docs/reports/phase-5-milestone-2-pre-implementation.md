# Phase 5 — Milestone 2 Pre-Implementation Report: Authentication & User Management

## 1. FastAPI Authentication Architecture
The backend will utilize **OAuth2 with Password (and bearer token)** flow using FastAPI's built-in `fastapi.security.OAuth2PasswordBearer`. This allows standard REST authentication mechanisms where the client receives a token after presenting credentials and passes it in the `Authorization` header as a Bearer token.

## 2. User Registration/Profile Creation
Users will register by providing their phone number, name, and selecting a role (Farmer, Bulk Buyer, FPO, Logistics). The backend will create a user record in the PostgreSQL `users` table. If the phone number already exists, a 409 Conflict will be raised to ensure uniqueness.

## 3. OTP Authentication Strategy
- **Production:** A third-party SMS gateway (e.g., Twilio, AWS SNS) will be integrated in future phases. During Milestone 2, we will scaffold the OTP request/verify endpoint contracts but simulate the SMS delivery on the backend (logging the OTP to the server console instead of sending an SMS).
- **Development/Mock:** The Flutter mock application currently uses `123456` as the hardcoded OTP. This mock behavior will strictly remain isolated in `MockAuthRepository`. The remote FastAPI implementation will utilize a randomly generated 6-digit OTP stored temporarily with an expiration timestamp.

## 4. JWT/Session Architecture
FastAPI will generate **JSON Web Tokens (JWT)** upon successful OTP verification or password login. Sessions are strictly stateless. The backend will validate the cryptographic signature using the `JWT_SECRET` environment variable, ensuring the payload (user ID, role) hasn't been tampered with.

## 5. Access Token and Refresh Token Strategy
- **Access Token:** Short-lived token (e.g., 15 minutes) used for authenticating API requests.
- **Refresh Token:** Long-lived token (e.g., 7 days) used to request a new access token without requiring the user to re-authenticate.
- **Payload:** Will contain `sub` (user ID), `role`, and `exp` (expiration).

## 6. Password/Credential Handling
While OTP is the primary flow for the agricultural demographic, a password fallback mechanism will be supported at the DB level. If a password is provided during registration, it will be cryptographically hashed using **bcrypt** before storage. **No plaintext passwords will ever be stored.**

## 7. Role-Based Authorization
FastAPI dependencies will be leveraged to enforce RBAC (Role-Based Access Control) on protected routes:
- **Farmer:** Can create products, submit offers.
- **FPO:** Can manage aggregated data (future capability).
- **Bulk Buyer:** Can create bulk requirements, accept/reject offers.
- **Logistics:** Can view/update delivery status (future capability).
- **Admin:** God-mode over the system (managed directly via DB or future admin panel).

## 8. PostgreSQL User Model Mapping
The `User` model in PostgreSQL maps directly to the Flutter `UserEntity`:
- `id` (int) -> `id` (String - Flutter converts int to string for flexibility)
- `phone_number` (String) -> `phoneNumber` (String)
- `name` (String) -> `name` (String)
- `role` (String) -> `userType` (Enum: Farmer, Buyer, etc.)

## 9. API Endpoints and Contracts
- `POST /api/v1/auth/request-otp`:
  - Req: `{"phone_number": "+91XXXXXXXXXX"}`
  - Res: `{"message": "OTP sent"}`
- `POST /api/v1/auth/verify-otp`:
  - Req: `{"phone_number": "+91XXXXXXXXXX", "otp": "123456"}`
  - Res: `{"access_token": "ey...", "refresh_token": "ey...", "token_type": "bearer"}`
- `POST /api/v1/auth/register`:
  - Req: `{"phone_number": "...", "name": "...", "role": "FARMER"}`
  - Res: `User Schema`
- `POST /api/v1/auth/refresh`:
  - Req: `{"refresh_token": "ey..."}`
  - Res: `{"access_token": "ey...", "token_type": "bearer"}`
- `GET /api/v1/auth/me`:
  - Req: *Requires Bearer Token*
  - Res: `User Schema`

## 10. Authentication Error Responses
Errors will be mapped to standard HTTP statuses and unified JSON contracts to ensure Flutter can parse and map them to localized strings:
- **401 Unauthorized:** Invalid token, expired token, or wrong OTP.
- **403 Forbidden:** User lacks the necessary role.
- **404 Not Found:** User does not exist.
- **409 Conflict:** Phone number already registered.

## 11. Token Expiration and Refresh Handling
When the Flutter client receives a 401 Unauthorized on a standard API call, a Dio interceptor (or custom HTTP wrapper) will automatically call the `/refresh` endpoint using the stored refresh token. If successful, it will retry the original request. If the refresh token is also expired, the user will be logged out.

## 12. Secure Token Storage on Flutter
Tokens will **not** be stored in SharedPreferences. Instead, the `flutter_secure_storage` package will be utilized to encrypt the JWT securely on the device (using Keychain on iOS and EncryptedSharedPreferences on Android).

## 13. Migration Strategy to RemoteAuthRepository
- Create a new Flutter repository: `ApiAuthRepository implements AuthRepository`.
- Implement all existing domain interface methods (`login`, `verifyOtp`, `logout`, `getCurrentUser`).
- Connect this new repository to the Flutter Provider system using an environment-based configuration toggle.

## 14. Preserving Mock Authentication for Tests/Development
- The `MockAuthRepository` will remain untouched.
- A flag in `main.dart` or via `--dart-define=USE_API_BACKEND=true` will dictate whether the app injects `MockAuthRepository` or `ApiAuthRepository`.
- All 46 existing Flutter tests will continue to inject the `MockAuthRepository`, guaranteeing zero test breakages.

## 15. Profile Completion Workflow
If a user authenticates successfully but their profile lacks a name or role, the API will still issue a token. However, the `GET /api/v1/auth/me` response will indicate incomplete profile data, triggering the existing profile completion screens in the Flutter UI.

## 16. Protected API Routes
Dependencies such as `get_current_user` and `require_role(["FARMER"])` will be added to the FastAPI endpoints for products, requirements, and AI chats, ensuring complete endpoint security.

## 17. CORS and Security Configuration
- FastAPI will use `CORSMiddleware` configured strictly to allow connections only from trusted origins (or `*` during initial local development).
- Passwords (if used) will utilize the `passlib[bcrypt]` library for hashing.

## 18. Testing Strategy
- **Backend:** Fast, isolated `pytest` routines using `TestClient` to verify OTP flow, JWT generation, token decoding, and RBAC rejections.
- **Frontend:** Existing tests remain. New integration tests could be added in later phases to hit the API, but are currently unnecessary for preserving UI functionality.

## 19. Backward Compatibility
The API responses will perfectly match the existing Flutter `UserEntity` models. The UI state management and localized ARB strings will require absolutely no modifications, as the exact same error exceptions and data structures will be yielded by the new repository.

## 20. Exact Files to Create/Modify
**Backend (Created/Modified):**
- `backend/app/core/security.py` (JWT and password hashing functions)
- `backend/app/api/deps.py` (Dependency injection for get_current_user)
- `backend/app/api/routes/auth.py` (Authentication endpoints)
- `backend/app/services/auth_service.py` (OTP and login logic)
- `backend/app/schemas/user.py` (Pydantic validation schemas)
- `backend/tests/api/test_auth.py`

**Flutter (Created/Modified):**
- `pubspec.yaml` (Add `flutter_secure_storage`, `http`/`dio`)
- `lib/features/auth/data/repositories/api_auth_repository.dart`
- `lib/core/network/api_client.dart` (For centralizing tokens and base URLs)
- `lib/main.dart` (Toggle dependency injection)

## 21. Implementation Milestones and Rollback Strategy

### Recommended Implementation Sequence:
1. **Backend Auth Scaffolding:** Implement `security.py`, schemas, and `auth.py` routes. Add backend unit tests.
2. **Flutter Network Setup:** Add dependencies (`http`, `flutter_secure_storage`), create the `ApiClient` that reads `--dart-define=API_BASE_URL`.
3. **Flutter Repository Creation:** Build `ApiAuthRepository`.
4. **Integration & Toggle:** Update `main.dart` to optionally inject the new remote repository. Verify login works against the FastAPI backend locally.

### Rollback Strategy:
If any critical issues arise on the frontend, simply toggle `--dart-define=USE_API_BACKEND=false` (or the equivalent bool in `main.dart`) to immediately revert to `MockAuthRepository`. This guarantees 100% safety and zero downtime.
