import httpx
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy import create_engine

from app.main import app
from app.db.database import get_db
from app.core.config import settings

from app.models import Base
from app.models.user import User
from app.models.auth import OTPCode, RefreshToken
from app.models.product import Product
from app.models.bulk import BulkRequirement, BulkOffer
from app.models.order import Order, OrderItem

# Test DB configuration
SQLALCHEMY_DATABASE_URL = "sqlite+aiosqlite:///./test_auth.db"
engine = create_async_engine(SQLALCHEMY_DATABASE_URL, echo=False)
TestingSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def override_get_db():
    async with TestingSessionLocal() as session:
        yield session

sync_engine = create_engine("sqlite:///./test_auth.db")

@pytest.fixture(autouse=True)
def setup_db():
    app.dependency_overrides[get_db] = override_get_db
    Base.metadata.create_all(sync_engine)
    yield
    Base.metadata.drop_all(sync_engine)
    app.dependency_overrides.clear()

@pytest.mark.asyncio
async def test_register():
    async with AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.post(
            f"{settings.API_V1_STR}/auth/register",
            json={"phone_number": "+911234567890", "name": "Test Farmer", "role": "farmer", "password": "pass"}
        )
    assert response.status_code == 201
    assert response.json()["phone_number"] == "+911234567890"

@pytest.mark.asyncio
async def test_request_and_verify_otp():
    async with AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Register user
        await ac.post(
            f"{settings.API_V1_STR}/auth/register",
            json={"phone_number": "+910987654321", "name": "Buyer", "role": "retail_buyer"}
        )
        
        # 2. Request OTP
        req_response = await ac.post(
            f"{settings.API_V1_STR}/auth/request-otp",
            json={"phone_number": "+910987654321"}
        )
        assert req_response.status_code == 200
        dev_otp = req_response.json()["dev_otp"]
        assert dev_otp is not None
        
        # 3. Verify OTP
        verify_response = await ac.post(
            f"{settings.API_V1_STR}/auth/verify-otp",
            json={"phone_number": "+910987654321", "otp": dev_otp}
        )
        assert verify_response.status_code == 200
        data = verify_response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        
        # 4. Access protected route (me)
        token = data["access_token"]
        me_response = await ac.get(
            f"{settings.API_V1_STR}/auth/me",
            headers={"Authorization": f"Bearer {token}"}
        )
        assert me_response.status_code == 200
        assert me_response.json()["role"] == "retail_buyer"
