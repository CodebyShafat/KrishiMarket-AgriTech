from sqlalchemy import Column, Integer, String, DateTime, Float, ForeignKey
from sqlalchemy.sql import func
from app.db.database import Base

class Order(Base):
    __tablename__ = "orders"

    id = Column(String, primary_key=True, index=True)
    buyer_id = Column(String, nullable=False, index=True)
    total_amount = Column(Float, nullable=False)
    status = Column(String, default="PLACED")
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(String, primary_key=True, index=True)
    order_id = Column(String, ForeignKey("orders.id"), nullable=False)
    product_id = Column(String, nullable=False) # References products.id
    quantity = Column(Float, nullable=False)
    price_at_time = Column(Float, nullable=False)
