# Phase 5 Pre-Implementation Report: FastAPI Backend & Persistence Layer

## 1. Current Phase 1–4B Architecture
The current KrishiMarket application is entirely client-side, built with Flutter. It utilizes a Clean Architecture pattern divided into Domain, Data, and Presentation layers. 
- **State Management:** Provider is used for reactive state management.
- **Data Layer:** Entirely driven by `Mock*Repository` implementations (e.g., `MockProductRepository`, `MockBulkMarketplaceRepository`, `MockAuthRepository`). Data is stored in-memory, meaning it resets on every app launch.
- **AI Integration:** Includes a mock AI assistant and an API repository structure that is ready but currently interacts with a simulated endpoint.
- **Localization:** 12-language localization heavily relies on `AppLocalizations` triggered reactively via UI changes.

## 2. Proposed FastAPI Backend Architecture
The backend will be a robust, production-grade API built with **FastAPI** (Python).
- **Core Framework:** FastAPI for high-performance, asynchronous REST APIs.
- **Validation:** Pydantic for request/response contract validation.
- **ORM:** SQLAlchemy 2.0 for database interactions using asynchronous drivers.
- **Migrations:** Alembic for schema versioning and database migrations.
- **Architecture:** Layered design consisting of Routers (Endpoints), Services (Business Logic), Repositories (Data Access), and Models (SQLAlchemy).

## 3. Database Choice and Justification
**PostgreSQL** is the chosen database.
- **Justification:** Agricultural marketplaces require strict ACID compliance, especially for financial transactions, inventory decrements, and partial fulfillment calculations. PostgreSQL provides excellent relational integrity, robust transaction handling, and native JSONB support if dynamic agricultural parameters are needed in the future.

## 4. Complete Database Schema
*Note: Primary keys are UUIDs or Auto-incrementing Integers. Created/Updated timestamps exist on all tables.*

- **Users:** `id`, `phone_number` (unique), `name`, `role` (Farmer, Buyer, etc.), `hashed_password`
- **Products:** `id`, `farmer_id` (FK), `title`, `crop_type`, `price`, `quantity`, `unit`, `description`
- **BulkRequirements:** `id`, `buyer_id` (FK), `crop_type`, `required_quantity`, `unit`, `target_price`, `fulfilled_quantity`, `status` (OPEN, PARTIAL, FULFILLED, CANCELLED)
- **BulkOffers:** `id`, `requirement_id` (FK), `farmer_id` (FK), `offered_quantity`, `price`, `status` (PENDING, ACCEPTED, REJECTED)
- **Orders:** `id`, `buyer_id` (FK), `total_amount`, `status` (PLACED, PREPARING, DELIVERED, CANCELLED)
- **OrderItems:** `id`, `order_id` (FK), `product_id` (FK), `quantity`, `price_at_time`
- **AIConversations:** `id`, `user_id` (FK), `context_data`
- **AIMessages:** `id`, `conversation_id` (FK), `role` (user/assistant), `content`, `intent`, `parameters` (JSON), `requires_confirmation`

## 5. User/Authentication Architecture
- **Backend:** FastAPI will generate **JWT (JSON Web Tokens)** upon successful login/registration.
- **Frontend:** Flutter will store the JWT securely using `flutter_secure_storage`.
- **Flow:** The Flutter client will include the JWT in the `Authorization: Bearer <token>` header for all subsequent API requests. The backend will validate the token using a dependency injection mechanism.

## 6. Farmer, FPO, Bulk Buyer, and Logistics Roles
Role-Based Access Control (RBAC) will be enforced at the API route level.
- **Farmer:** Can POST products, POST bulk offers, and GET orders assigned to their products.
- **Bulk Buyer:** Can POST bulk requirements, PUT (accept/reject) bulk offers, and POST cart orders.
- **FPO (Farmer Producer Organization):** Can aggregate data, create collective listings, and view analytics (expanded in future phases).
- **Logistics:** Can GET assigned orders and PUT delivery statuses (expanded in future phases).

## 7. Marketplace API Contracts
- `GET /api/v1/products` - List products (with query filters for crop, price, etc.)
- `POST /api/v1/products` - Create a listing (Farmer only)
- `GET /api/v1/products/{id}` - Get product details
- `POST /api/v1/orders` - Place a standard marketplace order

## 8. Bulk Requirement and Offer APIs
- `GET /api/v1/requirements` - List open bulk requirements
- `POST /api/v1/requirements` - Create requirement (Buyer only)
- `GET /api/v1/requirements/{id}/offers` - View offers for a requirement
- `POST /api/v1/requirements/{id}/offers` - Submit an offer (Farmer only)
- `PUT /api/v1/offers/{id}/status` - Accept or reject an offer (Buyer only)

## 9. Partial Fulfillment Persistence
- The business logic for partial fulfillment will reside in the FastAPI Service layer.
- When an offer is ACCEPTED via `PUT /api/v1/offers/{id}/status`, an atomic SQL transaction will:
  1. Update the offer status to ACCEPTED.
  2. Add the `offered_quantity` to the requirement's `fulfilled_quantity`.
  3. Check if `fulfilled_quantity >= required_quantity`. If so, update the requirement status to FULFILLED.
- The use of database transactions ensures race conditions do not result in over-fulfillment.

## 10. AI/Gemini Proxy Architecture
- **Safety & Security:** The Flutter client will **never** hold the Gemini API key.
- **Flow:** Flutter sends user text to `POST /api/v1/ai/chat`.
- **Proxying:** FastAPI constructs the prompt with user context, calls the Gemini REST API securely, parses the JSON intent/parameters, and returns a standardized response contract to the Flutter client.

## 11. Authorization and Security
- Passwords (if used over OTP) will be hashed using `bcrypt`.
- FastAPI `Depends` will enforce `get_current_user` and `require_role(allowed_roles)`.
- CORS will be configured strictly.
- Input validation via Pydantic will prevent SQL injection and malformed data payloads.

## 12. API Error Handling
- FastAPI will use standardized HTTP exception handlers.
- Errors will return a unified JSON schema: `{"error_code": "INSUFFICIENT_STOCK", "message": "..."}`
- The Flutter Repositories will map these HTTP error codes to the existing `AppLocalizations` keys (e.g., `ai_network_error`, `actionError`), ensuring localization remains unbroken.

## 13. Flutter ↔ FastAPI Data Flow
- Flutter will use the `http` package (or `dio`) to make REST calls.
- `Api*Repository` classes will implement the existing Domain Repository interfaces.
- The Provider architecture remains unchanged. It will call `apiRepository.getProducts()`, which fetches JSON from FastAPI, maps it to `ProductEntity`, and updates the UI state.

## 14. Repository Migration Strategy
- **Do not delete Mock Repositories.**
- Create new files: `api_product_repository.dart`, `api_bulk_repository.dart`, etc., all implementing their respective Domain contracts.
- In `main.dart`, introduce an environment variable or configuration toggle (e.g., `USE_MOCK_DATA`) to inject either the Mock or API repository into the Providers.

## 15. Mock-to-Real Data Migration Strategy
- To maintain visual consistency, the hardcoded data currently residing in the Flutter mock repositories will be ported to an Alembic `seed_data.py` script.
- When the FastAPI database is initialized, the seed script will populate it with the exact same test products, bulk requirements, and users.

## 16. Environment/Configuration Strategy
- **Backend:** `.env` file loaded via `pydantic-settings` (DB_URL, GEMINI_API_KEY, JWT_SECRET).
- **Frontend:** `.env` via `flutter_dotenv` or Dart `--dart-define` for specifying `API_BASE_URL`.

## 17. Development and Production Environments
- **Local Dev:** SQLite (or local Postgres Docker container), local FastAPI running on `localhost:8000`, Flutter running on emulator pointing to `10.0.2.2`.
- **Production:** Managed PostgreSQL (AWS RDS / Supabase), FastAPI deployed on AWS ECS/Render, Flutter built as Release APK mapping to the production `api.krishimarket.com`.

## 18. Testing Strategy
- **Backend:** `pytest` using `TestClient` and an in-memory SQLite database for fast isolated API testing.
- **Frontend:** **Existing tests must not break.** UI/Provider tests will continue to inject the `Mock*Repository` to isolate Flutter logic from network dependencies.
- **Integration:** Add a new suite of integration tests that configure the API repositories to hit a staging backend.

## 19. Deployment Architecture
- Docker containerization for the FastAPI backend.
- CI/CD pipelines (GitHub Actions) to run `pytest` and `flutter test` automatically on PRs.
- Automatic deployment of the backend container upon merging to `main`.

## 20. Risks and Mitigation
- **Risk:** Network latency breaking the snappy UI feel. **Mitigation:** Implement loading indicators (already present in Providers) and optimistic UI updates for cart additions.
- **Risk:** Existing tests failing due to repository swaps. **Mitigation:** Strict dependency injection; tests will explicitly wire up Mock repositories.
- **Risk:** AI intents changing format from backend. **Mitigation:** Pydantic models on backend ensure strict adherence to the existing `AiMessageEntity` JSON contract expected by Flutter.

## 21. Exact Files that would be Created/Modified
**Created:**
- `backend/` directory (FastAPI app, requirements.txt, models, routers, schemas, dependencies).
- `lib/features/*/data/repositories/api_*_repository.dart` (Flutter implementations).
- `assets/.env` (Flutter config).

**Modified:**
- `lib/main.dart` (Dependency Injection logic).
- `pubspec.yaml` (Added `http` or `dio`, `flutter_dotenv`).

## 22. What Existing Phase 1–4B Code Must NOT be Broken
- Domain Entities (`ProductEntity`, `AiMessageEntity`, `BulkRequirementEntity`, etc.).
- UI Screens and Widgets (Zero UI changes required).
- Existing Providers (`CartProvider`, `AiAssistantProvider`, etc.).
- The 12-language `.arb` localization files and resolution logic.
- The AI explicit confirmation safety workflow.
- All 46+ existing Flutter unit/widget tests.

---

## Recommended Phase 5 Implementation Sequence (Milestones)

**Milestone 1: Backend Scaffolding & Database**
- Initialize FastAPI project.
- Configure SQLAlchemy and Alembic.
- Define DB Models (Users, Products, Requirements).
- Write initial Alembic migration and seed script.

**Milestone 2: Authentication API & Integration**
- Implement JWT generation in FastAPI.
- Create `ApiAuthRepository` in Flutter.
- Toggle Flutter DI to use API Auth; verify login flow against backend.

**Milestone 3: Standard Marketplace API**
- Implement CRUD endpoints for Products and Orders in FastAPI.
- Create `ApiProductRepository`.
- Toggle Flutter DI; verify product browsing and cart checkout works.

**Milestone 4: Bulk Marketplace API & Partial Fulfillment**
- Implement endpoints for Requirements and Offers.
- Implement transactional partial fulfillment logic in FastAPI.
- Create `ApiBulkMarketplaceRepository`.
- Toggle Flutter DI; verify bulk creation and offer acceptance logic.

**Milestone 5: AI Proxy API**
- Implement `/ai/chat` endpoint in FastAPI routing to Gemini.
- Update `ApiAiAssistantRepository` in Flutter to point to the new backend.
- Verify intent parsing and safety confirmations still function perfectly.
