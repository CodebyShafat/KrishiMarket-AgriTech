from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base

class Product(Base):
    __tablename__ = "products"

    id = Column(String, primary_key=True, index=True) # UUID or similar
    farmer_id = Column(String, nullable=False, index=True)
    title = Column(String, nullable=False)
    crop = Column(String, nullable=False)
    price = Column(Float, nullable=False)
    quantity = Column(Float, nullable=False)
    unit = Column(String, nullable=False)
    description = Column(String, nullable=True)
    image_url = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
