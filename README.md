# KrishiMarket

## Overview
KrishiMarket is a comprehensive marketplace connecting farmers directly with buyers. The platform facilitates end-to-end agricultural trade with integrated AI assistance, localized language support, and a robust backend.

## Main Features
- **Farmer Marketplace:** Direct listing of agricultural products
- **Product Management:** Inventory, pricing, and availability controls
- **Customer Marketplace:** Browse, search, and filter farm products
- **Cart & Checkout:** Seamless bulk ordering and fulfillment
- **Orders:** Track current and past agricultural orders
- **AI Assistant:** Voice-driven AI for product search and platform navigation
- **Multilingual Support:** Fully localized (English, Hindi, Bengali, Marathi, etc.)
- **Authentication:** Secure phone-based login and Role-Based Access Control (RBAC)

## Architecture
- **Flutter:** Multi-platform frontend UI/UX
- **FastAPI:** High-performance async Python backend
- **Services:** Decoupled business logic (Auth, AI, Marketplace)
- **SQLAlchemy:** Asynchronous ORM for data modeling
- **SQLite:** Lightweight local database (easily migratable to PostgreSQL)

## Project Structure
```text
KrishiMarket/
├── android/          # Native Android configuration
├── ios/              # Native iOS configuration
├── web/              # Web compilation targets
├── windows/          # Native Windows configuration
├── linux/            # Native Linux configuration
├── macos/            # Native macOS configuration
├── lib/              # Main Flutter application source
├── test/             # Flutter unit & widget tests
├── backend/          # FastAPI Python backend
│   ├── app/          # Backend application source
│   ├── tests/        # Python backend tests
│   ├── requirements.txt
│   └── .env.example  # Safe environment template
├── scripts/          # Development and migration scripts
│   ├── generate/     # Auto-generation scripts
│   ├── migration/    # Localization/migration tools
│   └── verification/ # DB and endpoint verifiers
├── docs/             # Project documentation
│   └── reports/      # Historical audits and architectural reports
```

## Requirements
- **Flutter SDK:** ^3.13.1
- **Python:** 3.10+
- **OS:** Windows / macOS / Linux

## Setup

1. **Clone repository:**
   ```bash
   git clone <repository_url>
   cd KrishiMarket
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure backend environment:**
   Copy `backend/.env.example` to `backend/.env` and update credentials.

4. **Create Python virtual environment:**
   ```bash
   cd backend
   python -m venv venv
   # On Windows:
   .\venv\Scripts\activate
   # On macOS/Linux:
   source venv/bin/activate
   ```

5. **Install backend requirements:**
   ```bash
   pip install -r requirements.txt
   ```

6. **Start FastAPI:**
   ```bash
   python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
   ```

7. **Start Flutter Web:**
   Open a new terminal at the project root and run:
   ```bash
   flutter run -d chrome
   ```

## Environment Variables
The backend configuration is managed via `backend/.env`. Refer to `backend/.env.example` for the required keys (e.g., `DATABASE_URL`, `JWT_SECRET`, `GEMINI_API_KEY`). **Never put real credentials in version control.**

## Testing

**Flutter Tests:**
```bash
flutter analyze
flutter test
```

**Backend Tests:**
```bash
cd backend
pytest
```

## Development OTP
> **Note:** Real SMS OTP is not implemented yet.
> Use OTP **123456** which is configured for DEVELOPMENT ONLY.

## Team Development Notes
- **Flutter code** lives in `lib/`.
- **Backend code** lives in `backend/app/`.
- **Tests** live in `test/` (Frontend) and `backend/tests/` (Backend).
- **Scripts** live in `scripts/`. Use these strictly for one-off scaffolding or data migrations.
- **Documentation** lives in `docs/reports/` containing detailed audit histories and verification logs.
