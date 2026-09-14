from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import List

class OrderItemCreate(BaseModel):
    product_id: str
    quantity: float

class OrderCreate(BaseModel):
    items: List[OrderItemCreate]

class OrderItemResponse(BaseModel):
    id: str
    order_id: str
    product_id: str
    quantity: float
    price_at_time: float
    product_name: str | None = None
    farmer_id: str | None = None
    farmer_name: str | None = None
    unit: str | None = None
    
    model_config = ConfigDict(from_attributes=True)

class OrderResponse(BaseModel):
    id: str
    buyer_id: str
    total_amount: float
    status: str
    created_at: datetime
    items: List[OrderItemResponse] = []
    
    model_config = ConfigDict(from_attributes=True)
