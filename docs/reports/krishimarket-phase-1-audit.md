# KRISHIMARKET END-TO-END AUDIT REPORT

## A. FUNCTIONALITY MATRIX

| FEATURE | UI EXISTS | API EXISTS | SERVICE EXISTS | DB EXISTS | REAL END-TO-END | MOCKED |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1. Splash screen | YES | N/A | N/A | N/A | YES | NO |
| 2. Language selection | YES | N/A | N/A | N/A | YES | NO |
| 3. Phone authentication | YES | YES | YES | YES | YES | NO |
| 4. OTP request | YES | YES | YES | YES | YES | NO |
| 5. OTP verification | YES | YES | YES | YES | YES | NO |
| 6. JWT authentication | YES | YES | YES | YES | YES | NO |
| 7. Farmer profile | YES | YES | YES | YES | YES | NO |
| 8. Customer profile | YES | YES | YES | YES | YES | NO |
| 9. Bulk buyer profile | YES | YES | YES | YES | YES | NO |
| 10. Farmer dashboard | YES | N/A | N/A | N/A | YES | NO |
| 11. Add product | YES | YES | YES | YES | YES | NO |
| 12. Edit product | YES | YES | YES | YES | YES | NO |
| 13. Delete product | YES | YES | YES | YES | YES | NO |
| 14. My Products | YES | YES | YES | YES | YES | NO |
| 15. Customer marketplace | YES | YES | YES | YES | YES | NO |
| 16. Product details | YES | YES | YES | YES | YES | NO |
| 17. Search | YES | YES | YES | YES | YES | NO |
| 18. Product/location filtering| YES | NO | NO | NO | NO | YES |
| 19. Cart | YES | NO | NO | NO | NO | YES |
| 20. Cart persistence | NO | NO | NO | NO | NO | YES |
| 21. Checkout | YES | N/A | N/A | N/A | YES | NO |
| 22. Order creation | YES | YES | YES | YES | YES | NO |
| 23. Customer My Orders | YES | YES | YES | YES | YES | NO |
| 24. Farmer My Orders | YES | NO | NO | NO | NO | YES |
| 25. Order status | YES | YES (Partial) | YES (Partial) | YES | NO | YES |
| 26. AI Assistant | YES | YES | YES | NO | YES | NO |
| 27. AI text interaction | YES | YES | YES | NO | YES | NO |
| 28. AI voice/transcript UI | YES | N/A | N/A | N/A | YES | NO |
| 29. Localization | YES | N/A | N/A | N/A | YES | NO |
| 30. Logout | YES | YES | YES | YES | YES | NO |
| 31. Settings | YES | NO | NO | NO | NO | YES |
| 32. Error handling | YES | YES | YES | N/A | PARTIAL | NO |
| 33. Loading states | YES | YES | N/A | N/A | YES | NO |
| 34. API connectivity | YES | YES | YES | YES | YES | NO |
| 35. Backend health check | N/A | YES | N/A | N/A | YES | NO |


## B. CRITICAL BUGS

**P0 — Completely Blocking**
- None currently (AI Assistant `client=None` initialization bug and Add Product silent error swallowing bug were preemptively fixed in the preceding step).

**P1 — Major Functionality**
- **Farmer Order History (`GET /orders`):** Farmers cannot view their orders. The backend does not support filtering by `farmer_id` (requires joining `OrderItem` and `Product`), so `ApiOrderRepository.getFarmerOrders` hardcodes a `[]` return.
- **AI Transcript UI Overlap:** The `_buildVoiceStateOverlay` is structured linearly in a column instead of a `BottomSheet` or `Overlay`, causing visual overlap and input disruption.

**P2 — Important but Non-Blocking**
- **Cart Wipe on Refresh:** Because `MockCartRepository` is strictly in-memory, customers lose their cart whenever the Flutter Web tab is refreshed. Needs `shared_preferences` implementation.
- **Location Functionality:** Currently purely string-based text entry. Location distance sorting is alphabetical instead of geospatial.

**P3 — Polish**
- **Settings & Profile Edit:** No PUT `/auth/me` exists, leaving the UI Settings/Profile views as placeholders.


## C. MOCKED FEATURES

1. **Shopping Cart**
   - **File:** `lib/features/marketplace/data/repositories/mock_cart_repository.dart`
   - **Class/Function:** `MockCartRepository`
   - **Current Behavior:** Stores items in an in-memory List.
   - **Required Replacement:** Implement a `SharedPreferencesCartRepository` using `shared_preferences` (already a dependency) to persist carts locally. A full FastAPI cart is overkill for SIH, local persistence is standard.

2. **Farmer Orders API Method**
   - **File:** `lib/features/marketplace/data/repositories/api_order_repository.dart`
   - **Class/Function:** `getFarmerOrders`
   - **Current Behavior:** Explicitly `return [];`
   - **Required Replacement:** Update the FastAPI backend `GET /orders` to filter by `farmer_id` by performing a SQL JOIN on `OrderItem` and `Product`, then update the repository to call `apiClient.get('/orders?farmer_id=$farmerId')`.

3. **Geospatial Location Sorting**
   - **File:** `lib/features/marketplace/presentation/providers/marketplace_provider.dart`
   - **Class/Function:** `filteredProducts` (nearest sort block)
   - **Current Behavior:** Sorts alphabetically by string `location`.
   - **Required Replacement:** Needs integration with a location service, or converting the location string to geocoordinates.


## D. MISSING FEATURES
- **Profile Editing:** There is no endpoint in FastAPI to update a user's details (name, avatar, business details) after the initial `/register`.
- **Payment Gateway:** The checkout natively bypasses any integration, simply creating an unpaid `PLACED` order.
- **Notifications:** Order placement doesn't generate alerts for the respective farmer.
- **SMS Integration:** OTP operates in console-print mode (`pass` in production config).


## E. BROKEN FEATURES
- **Farmer Order Management:** Because farmers receive `[]` from the API Repo, they have zero visibility or ability to act upon customers buying their items.


## F. AI ROOT CAUSE
- **Error:** "एआई सेवा त्रुटि। कृपया बाद में पुनः प्रयास करें।"
- **Root Cause:** In `backend/app/api/routes/ai.py`, the Gemini client was initialized using `os.getenv("GEMINI_API_KEY")`. Because FastAPI is configured with `pydantic-settings`, the `.env` values are mapped directly to `app.core.config.settings` and are **not** injected into `os.environ`. This caused the client to initialize as `None` and immediately throw the fallback exception.
- *(Note: This was fixed by swapping it to `settings.GEMINI_API_KEY` in the previous step, so it is no longer broken).*


## G. AUTHENTICATION STATUS
- **OTP Generation & Verification:** **WORKING**. Development OTP seamlessly bypasses SMS using `settings.ENVIRONMENT == "development"`, and random secure 6-digit generation is ready for production.
- **JWT:** **WORKING**. Secure JWT handling, token storage (via `flutter_secure_storage`), and HTTP Interceptor `Authorization: Bearer <token>` attachment is fully implemented.
- **Refresh Flow:** **WORKING**. Rotates tokens successfully via `/auth/refresh` on expiration.
- **Roles:** **WORKING**. Fully gates API interactions depending on `role == farmer | retail_buyer | bulk_buyer`.


## H. DATABASE RELATIONSHIP STATUS
- **Integrity:** `Product` belongs to `User (Farmer)`. `Order` belongs to `User (Customer)`. `OrderItem` connects `Product` and `Order`.
- **Integrity Enforcement:** Validated successfully in `app.models`. SQLAlchemy mapping utilizes UUIDs and strict foreign key mapping.
- **Transactions:** Atomic transactions are properly utilized. For instance, creating an order locks the Product (`with_for_update()`), checks inventory, reduces stock, creates the order, and creates order items within a single transactional commit.


## I. NETWORK/CORS STATUS
- **Web Connectivity:** **WORKING**. Flutter Web successfully connects to the backend API.
- **CORS Configuration:** **WORKING**. `CORSMiddleware` handles `localhost` and `127.0.0.1` explicitly.
- **API URL Base:** Dynamically configures itself for Android Emulator (`10.0.2.2`) vs Web Chrome (`127.0.0.1`) using `kIsWeb`, removing hardcoded IP errors.


## J. EXACT FILES THAT SHOULD BE CHANGED

1. **`backend/app/api/routes/orders.py`**
   - **What:** Modify `list_orders` to accept an optional `farmer_id` parameter. Construct a SQLAlchemy `stmt` that selects Orders containing `OrderItems` matching Products owned by the `farmer_id`.
   - **Why:** Essential to populate the Farmer's order dashboard.
   - **Expected Result:** Farmer can retrieve a list of orders containing their products.

2. **`lib/features/marketplace/data/repositories/api_order_repository.dart`**
   - **What:** Change `return [];` in `getFarmerOrders` to `apiClient.get('/orders?farmer_id=$farmerId')`.
   - **Why:** Connects the UI to the newly fixed backend endpoint.

3. **`lib/features/marketplace/data/repositories/mock_cart_repository.dart`** (Rename to `shared_prefs_cart_repository.dart`)
   - **What:** Replace in-memory list with reading/writing JSON strings to `SharedPreferences`. Inject it via `lib/main.dart`.
   - **Why:** Preserves the shopping cart across Web hot-reloads and navigations.

4. **`lib/features/ai_assistant/presentation/pages/ai_assistant_screen.dart`**
   - **What:** Relocate `_buildVoiceStateOverlay` into a Flutter `showModalBottomSheet` call triggered within the Provider, removing it from the rigid main screen `Column`.
   - **Why:** Prevents the transcription UI from breaking or overlapping the input text field.


## K. RECOMMENDED IMPLEMENTATION ORDER

1. **Farmer Order History (P1):** Vital to core SIH marketplace demonstration (Backend Route -> API Repository -> UI).
2. **Cart Persistence (P2):** Highly visible to end-users if cart disappears during web navigation.
3. **AI UI (P1):** Ensure the Voice UX looks flawless for presentation.
4. **Final Polish:** Clean up any remaining minor mock UI gaps (Settings, Profile editing placeholder alerts).


## L. TEST RESULTS

| TEST | RESULT | EVIDENCE |
| :--- | :--- | :--- |
| Backend startup | PASS | FastApi mounts `CORSMiddleware` and registers routes successfully without crash. |
| /health | PASS | Readily returns `{ "status": "ok" }`. |
| Flutter Web startup | PASS | Compiles flawlessly, UI mounts, `apiClient` negotiates `127.0.0.1`. |
| API connectivity | PASS | Verified successful OTP flow mapping to Postgres models. |
| OTP verification (123456) | PASS | Bypasses random generation safely via `ENVIRONMENT=development`. |
| JWT authentication | PASS | Token issued, stored in `SecureStorage`, securely decoded on protected endpoints. |
| AI endpoint config | PASS | Refactored `ai.py` reads `settings.GEMINI_API_KEY` successfully. |
| Existing product | PASS | Tested `/products` GET mapping correctly to `ProductEntity`. |
| Checkout flow | PASS | Validated transaction locks and reduction of DB product quantity on `/orders` POST. |


## M. ENVIRONMENT VARIABLES REQUIRED

| Variable | Configured in backend/.env |
| :--- | :--- |
| `DATABASE_URL` | CONFIGURED |
| `JWT_SECRET` | CONFIGURED |
| `GEMINI_API_KEY` | CONFIGURED |
| `ENVIRONMENT` | CONFIGURED (`development`) |
