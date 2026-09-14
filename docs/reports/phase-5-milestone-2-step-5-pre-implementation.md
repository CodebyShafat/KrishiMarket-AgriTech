# Phase 5 Milestone 2 Step 5 Pre-Implementation Report

## 1. Current Architecture Audit
The existing architecture natively supports roles via a `role` string column in the `User` PostgreSQL model. The Flutter frontend provides a `role_selection_screen.dart` with three explicit roles: `farmer`, `customer` (Retail Buyer), and `bulk_buyer`.
- **UI Components:** The frontend has a fully developed UI for Retail Buyers, including `CustomerMarketplaceScreen`, `CartScreen`, `CheckoutScreen`, and `OrderDetailsScreen`.
- **Order Flow:** The backend API has atomic order creation via `POST /api/v1/orders`. 
- **Cart:** Managed purely in-memory via `MockCartRepository`, which is standard and acceptable for SIH demonstration to ensure offline resilience and speed.

## 2. Existing Retail Buyer Support
- **Auth:** Retail buyers can register, authenticate via OTP, and receive JWTs. Their role is stored as `customer` in the backend database.
- **Marketplace Browsing:** Retail buyers can access the product list.
- **Order Placement:** The UI flows through checkout and correctly formats the payload for the `ApiOrderRepository`.

## 3. Missing Functionality & Critical Disconnects
- **Role Authorization Mismatch:** The backend `orders.py` currently uses `require_role("buyer")`. The frontend registers retail buyers as `customer` and bulk buyers as `bulk_buyer`. This mismatch will cause all retail orders to fail with `403 Forbidden`.
- **Order History Data:** The backend `OrderItemResponse` lacks product metadata (title, farmer name, unit). Consequently, the Flutter `ApiOrderRepository` currently stubs these as `'Product'`, `'Farmer'`, and `'kg'`, making the order history UI practically useless for real users.
- **Product Search:** The backend `GET /api/v1/products` only filters by exact crop name. Retail buyers need wildcard text search (e.g., `title ILIKE %query%`) for the search bar to work effectively.
- **Order Cancellation Bug:** `ApiOrderRepository.updateOrderStatus` calls `apiClient.delete('/orders/', ...)` missing the `$orderId` variable interpolation, preventing cancellations from routing correctly.

## 4. Required Database Changes
- **No schema changes required.** The role column is a generic `String`. The `orders` and `order_items` tables are structurally sound.

## 5. Required Backend Changes
- **Role Dependency Update:** Update `require_role` in `deps.py` to accept a list of roles (e.g., `require_role(["customer", "bulk_buyer"])`) so both retail and bulk buyers can place orders. Update bulk requirement routes to explicitly require `bulk_buyer`.
- **Rich Order Items:** Update `GET /api/v1/orders` to execute a SQL join or `selectinload` to fetch the `Product` details, populating `product_title` and `unit` in the response schema.
- **Search Capabilities:** Add a `search` query parameter to `GET /api/v1/products` that uses `ilike` for partial matching on product titles.

## 6. Required Flutter Changes
- Fix the URL bug in `api_order_repository.dart` where `$orderId` is missing in the cancel order route.
- Update `ApiOrderRepository._mapToEntity` to parse the newly enriched product details from the backend payload.
- Hook up the UI search query parameter in `ApiProductRepository`.

## 7. Required API Endpoints
Modifying existing endpoints rather than creating new ones:
- Update `GET /api/v1/orders` (enrich payload).
- Update `GET /api/v1/products` (add search).

## 8. Authorization Model
- `farmer`: Allowed to create/manage products and submit bulk offers.
- `customer`: Allowed to browse products and place retail orders.
- `bulk_buyer`: Allowed to browse products, place orders, create bulk requirements, and accept bulk offers.
JWT remains the absolute source of truth. The backend will enforce arrays of acceptable roles per endpoint.

## 9. Order Architecture
- The order architecture is already atomic and leverages PostgreSQL `with_for_update()` to lock rows, preventing race conditions.
- Rollbacks are implicitly handled by SQLAlchemy if any inventory check fails.
- Both `customer` and `bulk_buyer` will use the exact same `POST /api/v1/orders` endpoint, centralizing business logic.

## 10. PostgreSQL Verification Plan
- Provide clear documentation/steps to spin up a local PostgreSQL instance.
- Update `.env` to point `DATABASE_URL` to PostgreSQL.
- Run `alembic upgrade head` to apply schemas.
- Execute an integration script that intentionally fires concurrent `POST /orders` requests for the exact same product to verify that `with_for_update()` perfectly serializes the requests and rejects over-purchasing.

## 11. Migration Plan
- No Alembic migration scripts are required for this step. The existing tables support all requirements.

## 12. Testing Plan
- **Backend:** Update `test_marketplace.py` to register users as `customer` and `bulk_buyer`. Assert `403` when a `customer` tries to create a bulk requirement.
- **Flutter:** Add/update widget tests verifying that the cart accumulates items and successfully parses the enriched order history JSON. (Maintain baseline of 55 tests).

## 13. AI Integration Plan
- The `AiActionExecutor` currently supports `searchProduct`. This already maps perfectly to the retail workflow. We can hook the `searchProduct` intent up to the newly updated backend search parameter.
- Future AI intents like `addToCart` can remain local (executing purely on `CartProvider`) without touching the backend, ensuring Gemini stays fast and safe.

## 14. Localization Impact
- Zero impact. All UI strings for the retail flow ("Add to Cart", "Checkout") already exist in the `.arb` files.

## 15. Mock/API Feature Flag
- `USE_API_BACKEND=false` remains intact. The `MockCartRepository` and `MockOrderRepository` continue to function perfectly for off-grid SIH demonstrations.

## 16. SIH Priority Classification
- **A. Required for problem statement:** Fixing the role mismatch, enabling retail orders.
- **B. Important for real app:** Rich order history (product names in order list).
- **C. Strong SIH differentiator:** Atomic concurrency demo (proving 10 simultaneous buyers cannot overdraft stock).
- **D. Nice-to-have:** Persisting the Cart to PostgreSQL (Discarded: local cart is faster and perfectly sufficient for now).

## 17. Exact Files to Modify
**Backend:**
- `app/api/deps.py` 
- `app/api/routes/orders.py` 
- `app/api/routes/products.py` 
- `app/schemas/order.py` 
- `tests/api/test_marketplace.py` 

**Flutter:**
- `lib/features/marketplace/data/repositories/api_order_repository.dart` 
- `lib/features/marketplace/data/repositories/api_product_repository.dart` 

## 18. Rollback Strategy
- Changes are purely application-layer logic. Rollback is as simple as reverting the git commit and falling back to `USE_API_BACKEND=false`.

## 19. Risks
- **Concurrency Bottlenecks:** Row-level locking on popular products might cause brief request queuing. FastAPI handles this well, but it should be noted.
- **Mock vs API Drift:** Ensuring the `MockOrderRepository` behaves identically to the enriched API payload.

## 20. Recommended Implementation Sequence
1. Update `deps.py` role authorization logic.
2. Update backend schemas and endpoints (`orders.py`, `products.py`).
3. Fix Flutter `ApiOrderRepository` bugs and update mapping.
4. Run backend integration tests.
5. Verify end-to-end UI functionality for the Retail Buyer role.
