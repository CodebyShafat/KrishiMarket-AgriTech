# KrishiMarket FastAPI Backend

## Prerequisites
- Python 3.10+
- Docker (for PostgreSQL)

## Setup

1. Start the PostgreSQL database:
   ```bash
   docker-compose up -d
   ```

2. Create a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: .\venv\Scripts\Activate.ps1
   pip install -r requirements.txt
   ```

3. Configure environment variables:
   Copy `.env.example` to `.env` and fill in the values. The default DATABASE_URL in `.env.example` works with the docker-compose setup.

4. Run database migrations:
   ```bash
   alembic upgrade head
   ```

5. Seed the database (optional):
   ```bash
   python -m scripts.seed_data
   ```

6. Run the server:
   ```bash
   uvicorn app.main:app --reload
   ```

## Testing
Run tests using pytest:
```bash
pytest
```
