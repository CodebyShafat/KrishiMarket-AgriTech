import asyncio
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.database import AsyncSessionLocal, engine, Base
from app.models.user import User

async def seed():
    # Only seed if users table is empty
    async with AsyncSessionLocal() as session:
        # Example seeding logic to be expanded in later milestones
        print("Seeding database...")
        # Check if user exists
        # Add mock users matching the flutter mock data
        await session.commit()
    print("Database seeded successfully.")

if __name__ == "__main__":
    asyncio.run(seed())
