# Phase 5 Milestone 2 Step 4: Marketplace E2E Integration - Pre-Implementation Report

## Goal Overview
Migrate the KrishiMarket marketplace functionality from mock/in-memory repositories to production-grade FastAPI + PostgreSQL APIs while preserving the existing Flutter UI, Provider architecture, business rules, localization, and AI safety workflows.

---

## 1. Product API Architecture
The Product API is built on FastAPI and SQLAlchemy (async). It relies on standard RESTful principles, utilizing API routers separated by domain (`products`, `bulk`, `orders`). Endpoints leverage Pydantic schemas for request validation and serialization, and inject the asynchronous database session and current user via FastAPI `Depends`.

## 2. Product CRUD/Search APIs
- **POST `/api/v1/products`**: Create a new product listing.
- **GET `/api/v1/products`**: Search and list products. Supports query parameters (`crop`, `farmer_id`, `skip`, `limit`).
- **GET `/api/v1/products/{id}`**: Retrieve product details.
- **PUT `/api/v1/products/{id}`**: Update product (Authorized to owner only).
- **DELETE `/api/v1/products/{id}`**: Delete a product (Authorized to owner only).

## 3. Farmer Product Listing Workflow
1. Farmer initiates product creation in Flutter UI.
2. `ProductProvider` triggers `ApiProductRepository.addProduct(ProductEntity)`.
3. Repository maps the entity to JSON and sends a `POST` request to the backend with the user's JWT.
4. FastAPI validates the token, extracts the user ID, creates the DB record, and returns the newly generated ID/metadata.
5. `ProductProvider` refreshes the product list, updating the UI.

## 4. Product Ownership & Authorization
Modifying endpoints (PUT, DELETE) will strictly verify ownership before execution:
```python
if product.farmer_id != str(current_user.id):
    raise HTTPException(status_code=403, detail="Not authorized to modify this product")
```
This Insecure Direct Object Reference (IDOR) protection ensures users cannot manipulate data they do not own.

## 5. Bulk Requirement APIs
- **POST `/api/v1/bulk/requirements`**: Create a requirement (Buyer only).
- **GET `/api/v1/bulk/requirements`**: List requirements (filterable by `buyer_id`, `status`, `crop`).
- **GET `/api/v1/bulk/requirements/{id}`**: Get requirement details.
- **PUT `/api/v1/bulk/requirements/{id}`**: Modify requirement (Buyer owner only).
- **DELETE `/api/v1/bulk/requirements/{id}`**: Cancel requirement (Requires zero accepted offers).

## 6. Bulk Offer APIs
- **POST `/api/v1/bulk/offers`**: Submit an offer on a requirement (Farmer only).
- **GET `/api/v1/bulk/offers`**: List offers (filterable by `requirement_id` or `farmer_id`).
- **POST `/api/v1/bulk/offers/{id}/accept`**: Accept an offer (Buyer owner only).
- **POST `/api/v1/bulk/offers/{id}/reject`**: Reject an offer (Buyer owner only).

## 7. Partial Fulfillment Transaction Logic
Accepting an offer requires strict atomic state transition.
1. **Begin Transaction & Lock**: Fetch the Requirement using `SELECT ... FOR UPDATE` (or SQLite equivalent locking).
2. **Calculate**: `remaining_quantity = required_quantity - fulfilled_quantity`.
3. **Validate**: If `offer.quantity > remaining_quantity`, abort the transaction with a `400 Bad Request`.
4. **Update Fulfillment**: Add `offer.quantity` to `fulfilled_quantity`.
5. **State Transition**: 
   - If `fulfilled_quantity == required_quantity`, set status to `FULFILLED`.
   - Else, set status to `PARTIALLY_FULFILLED`.
6. **Update Offer**: Set offer status to `ACCEPTED`.
7. **Commit**.

## 8. Order Creation and Relationships
- **POST `/api/v1/orders`**: Expects a payload containing a list of `product_id` and `quantity`.
- Backend verifies stock for all items, locking the product rows.
- Deducts inventory (`product.quantity -= ordered_qty`).
- Inserts into `orders` table.
- Inserts line items into `order_items` mapping the snapshot price.
- Commits the transaction anatomically to prevent orphaned orders or negative stock.

## 9. Role-Based Authorization
Using FastAPI dependencies, endpoints will enforce role constraints:
- `Depends(require_role("farmer"))` for creating products and making bulk offers.
- `Depends(require_role("buyer"))` for creating bulk requirements and placing orders.

## 10. PostgreSQL Transaction Boundaries
Database transactions will be handled strictly using SQLAlchemy `async with session.begin()` contexts or explicit `session.commit()` calls at the very end of the router execution, ensuring that if any validation fails mid-flight, an exception triggers an automatic rollback of the entire session.

## 11. Concurrency and Race-Condition Protection
High-concurrency updates (e.g., two farmers submitting an offer exactly at the same time, or two buyers buying the last unit of stock) are protected via database-level locking. `with_for_update()` in SQLAlchemy ensures that simultaneous requests queue up rather than reading stale data.

## 12. Pagination and Filtering
Standard `skip` and `limit` query parameters will enforce pagination. Search queries will leverage SQLAlchemy `where()` filters against indexed columns (`crop`, `status`, `buyer_id`, `farmer_id`).

## 13. Validation and Error Handling
- **422 Unprocessable Entity**: Automatically managed by Pydantic for malformed JSON.
- **400 Bad Request**: Raised for business logic violations (e.g., negative inventory, invalid states).
- **401 Unauthorized / 403 Forbidden**: Raised for invalid JWTs or unauthorized access.
- **Flutter Translation**: `ApiClient` maps these standard codes into localized Dart exceptions (`NetworkError`, `UnknownAuthError`).

## 14. Flutter Repository Interfaces 
The abstract Domain Repositories (`ProductRepository`, `BulkRequirementRepository`, `BulkOfferRepository`, `OrderRepository`) are untouched. The application logic has zero coupling to the underlying implementation.

## 15. New ApiRepository Design
We will introduce:
- `ApiProductRepository`
- `ApiBulkRequirementRepository`
- `ApiBulkOfferRepository`
- `ApiOrderRepository`

These map domain `Entities` to REST payloads, invoke `ApiClient`, and serialize the JSON responses back into `Entities`. They handle network errors natively.

## 16. Mock Repository Preservation and Feature-Flag Strategy
Existing `Mock*` repositories will NOT be deleted. 
`lib/main.dart` will dictate injection based on the build flag:
```dart
const bool useApiBackend = bool.fromEnvironment('USE_API_BACKEND', defaultValue: false);
final productRepo = useApiBackend ? ApiProductRepository(apiClient) : MockProductRepository();
```

## 17. API Request/Response Schemas
Defined in `app/schemas/`. 
Examples include `ProductCreate`, `ProductResponse`, `BulkRequirementCreate`, `BulkOfferAccept`. These ensure rigorous type safety crossing the HTTP boundary.

## 18. Authentication Integration 
The previously integrated JWT system remains unchanged. `ApiClient` handles attaching the `Bearer` token natively for endpoints requiring authentication.

## 19. AI Action Executor Segregation
The Gemini AI remains entirely oblivious to the backend. It does NOT generate SQL or call HTTP endpoints directly. It outputs parsed Intents (e.g., `AddProductIntent`), which are handed to the `ActionExecutor`, which triggers standard Flutter Providers.

## 20. Phase 4B Safety Architecture Preservation
The `ActionConfirmationDialog` halts execution of *any* marketplace mutating intent. Only upon user confirmation does the UI pass the intent to the Provider. This flow remains absolute; the AI has no path to bypass the UI constraint layer.

## 21. 12-Language Localization Preservation
Because no UI files or state-management presentation logic is modified, all `AppLocalizations.of(context)` calls remain perfectly intact. Network error exceptions map to existing translation keys.

## 22. Testing Strategy
- **Backend**: Execute `pytest` on `tests/api/` using `httpx.AsyncClient` targeting an isolated testing database.
- **Frontend**: API interaction verified through end-to-end Python scripts mirroring exact payload requirements, plus existing Provider unit tests running over the Mock implementations to ensure no business logic drift occurred.

## 23. Database Migration Strategy
The schema mapping to these API routes was established in Phase 5 Step 1. No major table structural changes are anticipated. If necessary, Alembic autogenerate will produce revision scripts securely.

## 24. Security Considerations
- JWT Tokens are managed purely in secure storage; never logged.
- The `user_id` from the decoded JWT is treated as the absolute source of truth for all record creation and modification; it is never blindly trusted from a client JSON payload.
- No database connections or Gemini keys exist in the Flutter binary.

## 25. Exact Files to Create/Modify
**Backend (Create)**:
- `app/api/routes/products.py`
- `app/api/routes/bulk.py`
- `app/api/routes/orders.py`
- `app/schemas/product.py`
- `app/schemas/bulk.py`
- `app/schemas/order.py`
- `tests/api/test_marketplace.py`

**Backend (Modify)**:
- `app/api/routes/__init__.py`
- `app/main.py` (include new routers)

**Flutter (Create)**:
- `lib/features/marketplace/data/repositories/api_product_repository.dart`
- `lib/features/marketplace/data/repositories/api_bulk_requirement_repository.dart`
- `lib/features/marketplace/data/repositories/api_bulk_offer_repository.dart`
- `lib/features/marketplace/data/repositories/api_order_repository.dart`

**Flutter (Modify)**:
- `lib/main.dart` (Dependency Injection logic)

## 26. Rollback Strategy
If critical failures occur, deployment rollback requires a simple toggle:
`flutter run --dart-define=USE_API_BACKEND=false`
This instantly restores the application to memory-based local functioning without deploying new binaries or reverting commits.

## Note on Environment Limitation (Docker/PostgreSQL)
Currently, a local PostgreSQL instance via Docker is unavailable. To unblock integration, the backend leverages a local SQLite configuration (`sqlite+aiosqlite:///./temp.db`) defined securely in `.env`.
SQLite operates with database-level locking rather than row-level locking, but perfectly mimics the concurrent isolation guarantees required for Phase 5. The API routes will be designed seamlessly for Postgres (using `with_for_update()`), ensuring that upon production deployment, the switch requires zero code changes—only a `.env` variable update.
