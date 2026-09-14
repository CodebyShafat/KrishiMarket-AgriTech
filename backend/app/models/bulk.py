from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base

class BulkRequirement(Base):
    __tablename__ = "bulk_requirements"

    id = Column(String, primary_key=True, index=True)
    buyer_id = Column(String, nullable=False, index=True)
    crop = Column(String, nullable=False)
    required_quantity = Column(Float, nullable=False)
    unit = Column(String, nullable=False)
    target_price = Column(Float, nullable=False)
    fulfilled_quantity = Column(Float, default=0.0)
    status = Column(String, default="OPEN")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class BulkOffer(Base):
    __tablename__ = "bulk_offers"

    id = Column(String, primary_key=True, index=True)
    requirement_id = Column(String, ForeignKey("bulk_requirements.id"), nullable=False)
    farmer_id = Column(String, nullable=False, index=True)
    offered_quantity = Column(Float, nullable=False)
    price = Column(Float, nullable=False)
    status = Column(String, default="PENDING")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
