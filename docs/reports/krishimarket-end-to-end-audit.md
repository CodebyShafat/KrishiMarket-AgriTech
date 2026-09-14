# KrishiMarket End-to-End Functionality Audit

## A. WORKING FEATURES (True UI → API → DB integration)
1. **Authentication:** Phone login, random OTP generation (in Prod), dev OTP bypass (in Dev), JWT generation, storage, and JWT token rotation `/refresh` are fully functional and secure.
2. **Product Management (Farmer):** Adding, listing, updating, and deleting products fully route to FastAPI and persist in the SQLite DB.
3. **Marketplace (Retail Buyer):** Listing products, search, and category filtering pull from the live database.
4. **Bulk Requirements & Offers (Backend):** The database models and API endpoints for Bulk workflows (including atomic transactions for partial requirement fulfillment) are implemented and safe.
5. **Order Creation:** Customers can POST `/orders`. The backend successfully decreases product inventory, calculates totals, and creates order records.

## B. BROKEN FEATURES
1. **AI Assistant Chat Execution:**
   - **Status:** Fails unconditionally on Web/API.
   - **Root Cause:** In `backend/app/api/routes/ai.py`, the Gemini client initializes using `os.getenv("GEMINI_API_KEY")`. However, FastAPI uses `pydantic-settings` to parse the `.env` file, which does not automatically inject into `os.environ`. The client evaluates to `None`, triggering the fallback mock error: "एआई सेवा त्रुटि। कृपया बाद में पुनः प्रयास करें।"
   - **Frontend File:** `ai_assistant_screen.dart`
   - **Backend File:** `ai.py`
2. **Farmer Order History:**
   - **Status:** Farmers see empty order lists.
   - **Root Cause:** The endpoint `GET /orders` can filter by `buyer_id`, but lacks a `farmer_id` filter (which requires joining `OrderItem` and `Product`). `ApiOrderRepository.getFarmerOrders()` is explicitly hardcoded to return `[]` with the comment `// Backend does not support GET orders for farmer directly`.
   - **Backend File:** `orders.py`
3. **Silent Error Swallowing on Mutations:**
   - **Status:** API errors (400, 500) do not show in the UI for several forms.
   - **Root Cause:** In `add_product_screen.dart` and `checkout_screen.dart`, methods like `context.read<ProductProvider>().addProduct(product)` are called synchronously without `await`, and `Navigator.pop(context)` is called immediately. The UI transitions away before the API fails, hiding crucial backend errors (e.g. insufficient stock).
   - **Frontend File:** `add_product_screen.dart`, `checkout_screen.dart`

## C. MOCK / PLACEHOLDER FEATURES
1. **Shopping Cart:**
   - **Status:** Purely local/in-memory.
   - **Root Cause:** `lib/main.dart` injects `MockCartRepository()` regardless of `USE_API_BACKEND`. No FastAPI route or DB model exists for the cart. It wipes on page reload.
2. **AI Transcript UI:**
   - **Status:** Layout overlap/clunkiness.
   - **Root Cause:** `_buildVoiceStateOverlay` is stacked directly in a Column rather than a modal bottom sheet, awkwardly shifting the chat layout or overriding the input field entirely when active.
3. **Location Services:**
   - **Status:** String-based placeholder.
   - **Root Cause:** No GPS integration. The "nearest" sort algorithm simply sorts strings alphabetically.

## D. NOT IMPLEMENTED FEATURES
1. **Profile Editing:** No PUT `/auth/me` endpoint exists. Farmers cannot update their profile/avatar after onboarding.
2. **Push Notifications:** Order placement does not notify farmers; requires manual refreshing.
3. **SMS Delivery:** `auth_service.py` has a `pass` block for production SMS execution.
4. **Payment Gateway:** Orders are "placed" immediately without a checkout integration.

## E. IMPLEMENTATION PRIORITY ORDER

### P0 (Critical App Blockers)
1. **Fix AI Assistant Initialization:** Update `ai.py` to use `settings.GEMINI_API_KEY` instead of `os.getenv()`.
2. **Fix Silent Error Swallowing:** Update UI mutation screens (`add_product_screen.dart`, `checkout_screen.dart`) to `await` the provider calls and display `ScaffoldMessenger` errors on failure instead of blindly popping the navigator.

### P1 (Core SIH Functionality)
3. **Implement Farmer Order History:** Add `farmer_id` filtering to `GET /orders` on the backend, update `ApiOrderRepository`, and ensure farmers can manage orders.
4. **AI UI Polish:** Refactor the Voice Transcript UI overlap into a clean BottomSheet so text input is not visually broken during voice sessions.

### P2 (Important Features)
5. **Persist Shopping Cart:** Migrate the Cart to `shared_preferences` locally so it survives a web reload (a full backend cart is likely overkill for the prototype, but local persistence is a must).

### P3 (Polish)
6. Add placeholder profile editing and settings configurations.
