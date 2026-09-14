import httpx
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from app.main import app
from app.db.database import get_db
from app.models import Base
from app.core.config import settings

# Test database setup uses SQLite in memory/file for basic API verification
TEST_DATABASE_URL = "sqlite+aiosqlite:///./test_market.db"

engine = create_async_engine(TEST_DATABASE_URL, echo=False)
TestingSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

async def override_get_db():
    async with TestingSessionLocal() as session:
        yield session

import pytest_asyncio

@pytest_asyncio.fixture(autouse=True, scope="module")
async def setup_db():
    app.dependency_overrides[get_db] = override_get_db
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    app.dependency_overrides.clear()

async def get_auth_token(phone: str, role: str) -> str:
    async with AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test") as ac:
        req_response = await ac.post(f"{settings.API_V1_STR}/auth/request-otp", json={"phone_number": phone})
        dev_otp = req_response.json()["dev_otp"]
        verify_response = await ac.post(f"{settings.API_V1_STR}/auth/verify-otp", json={"phone_number": phone, "otp": dev_otp})
        
        # Override role in DB for tests
        async with TestingSessionLocal() as db:
            from app.models.user import User
            from sqlalchemy.future import select
            res = await db.execute(select(User).where(User.phone_number == phone))
            user = res.scalars().first()
            user.role = role
            await db.commit()
            
        return verify_response.json()["access_token"]

@pytest.mark.asyncio
async def test_products_crud():
    farmer_token = await get_auth_token("+1234", "farmer")
    retail_token = await get_auth_token("+5678", "retail_buyer")
    farmer_token_2 = await get_auth_token("+9999", "farmer")

    async with AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Create product
        res = await ac.post(
            f"{settings.API_V1_STR}/products",
            headers={"Authorization": f"Bearer {farmer_token}"},
            json={"title": "Wheat", "crop": "Wheat", "price": 100, "quantity": 50, "unit": "kg"}
        )
        assert res.status_code == 201
        product_id = res.json()["id"]

        # 2. Retrieve product
        res = await ac.get(f"{settings.API_V1_STR}/products/{product_id}")
        assert res.status_code == 200
        assert res.json()["title"] == "Wheat"

        # 3. List products
        res = await ac.get(f"{settings.API_V1_STR}/products")
        assert len(res.json()) == 1

        # 4. Update own product
        res = await ac.put(
            f"{settings.API_V1_STR}/products/{product_id}",
            headers={"Authorization": f"Bearer {farmer_token}"},
            json={"price": 120}
        )
        assert res.status_code == 200
        assert res.json()["price"] == 120

        # 5. Reject update by another farmer
        res = await ac.put(
            f"{settings.API_V1_STR}/products/{product_id}",
            headers={"Authorization": f"Bearer {farmer_token_2}"},
            json={"price": 90}
        )
        assert res.status_code == 403

        # 6. Reject delete by another farmer
        res = await ac.delete(
            f"{settings.API_V1_STR}/products/{product_id}",
            headers={"Authorization": f"Bearer {farmer_token_2}"}
        )
        assert res.status_code == 403

        # 7. Buyer cannot create product
        res = await ac.post(
            f"{settings.API_V1_STR}/products",
            headers={"Authorization": f"Bearer {retail_token}"},
            json={"title": "Rice", "crop": "Rice", "price": 100, "quantity": 50, "unit": "kg"}
        )
        assert res.status_code == 403

        # 8. Delete own product
        res = await ac.delete(
            f"{settings.API_V1_STR}/products/{product_id}",
            headers={"Authorization": f"Bearer {farmer_token}"}
        )
        assert res.status_code == 204

@pytest.mark.asyncio
async def test_bulk_workflow_and_fulfillment():
    farmer_token = await get_auth_token("+1234", "farmer")
    bulk_token = await get_auth_token("+5678", "bulk_buyer")
    retail_token = await get_auth_token("+8888", "retail_buyer")

    async with AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test") as ac:
        # Retail buyer cannot create bulk req
        res = await ac.post(
            f"{settings.API_V1_STR}/bulk/requirements",
            headers={"Authorization": f"Bearer {retail_token}"},
            json={"crop": "Corn", "required_quantity": 100, "unit": "kg", "target_price": 50}
        )
        assert res.status_code == 403

        # Bulk buyer can
        res = await ac.post(
            f"{settings.API_V1_STR}/bulk/requirements",
            headers={"Authorization": f"Bearer {bulk_token}"},
            json={"crop": "Corn", "required_quantity": 100, "unit": "kg", "target_price": 50}
        )
        assert res.status_code == 201
        req_id = res.json()["id"]

        # Create offer
        res = await ac.post(
            f"{settings.API_V1_STR}/bulk/offers",
            headers={"Authorization": f"Bearer {farmer_token}"},
            json={"requirement_id": req_id, "offered_quantity": 60, "price": 45}
        )
        assert res.status_code == 201
        offer_id_1 = res.json()["id"]

        # Accept offer (Partial fulfillment)
        res = await ac.post(
            f"{settings.API_V1_STR}/bulk/offers/{offer_id_1}/accept",
            headers={"Authorization": f"Bearer {bulk_token}"}
        )
        assert res.status_code == 200

@pytest.mark.asyncio
async def test_order_creation():
    farmer_token = await get_auth_token("+1234", "farmer")
    retail_token = await get_auth_token("+5678", "retail_buyer")
    bulk_token = await get_auth_token("+9999", "bulk_buyer")

    async with AsyncClient(transport=httpx.ASGITransport(app=app), base_url="http://test") as ac:
        # 1. Create two products
        res = await ac.post(
            f"{settings.API_V1_STR}/products",
            headers={"Authorization": f"Bearer {farmer_token}"},
            json={"title": "P1", "crop": "Crop", "price": 10, "quantity": 100, "unit": "kg"}
        )
        p1_id = res.json()["id"]
        
        # 2. Place valid order as retail
        res = await ac.post(
            f"{settings.API_V1_STR}/orders",
            headers={"Authorization": f"Bearer {retail_token}"},
            json={"items": [
                {"product_id": p1_id, "quantity": 10}
            ]}
        )
        assert res.status_code == 201
        order_id = res.json()["id"]

        # 3. Retrieve order and check rich metadata
        res = await ac.get(
            f"{settings.API_V1_STR}/orders",
            headers={"Authorization": f"Bearer {retail_token}"}
        )
        assert res.status_code == 200
        orders = res.json()
        assert len(orders) >= 1
        assert orders[0]["items"][0]["product_name"] == "P1"

        # 4. Place order as bulk buyer (valid)
        res = await ac.post(
            f"{settings.API_V1_STR}/orders",
            headers={"Authorization": f"Bearer {bulk_token}"},
            json={"items": [
                {"product_id": p1_id, "quantity": 10}
            ]}
        )
        assert res.status_code == 201
