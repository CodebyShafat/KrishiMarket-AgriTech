from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional

class ProductBase(BaseModel):
    title: str
    crop: str
    price: float
    quantity: float
    unit: str
    description: Optional[str] = None
    image_url: Optional[str] = None

class ProductCreate(ProductBase):
    pass

class ProductUpdate(BaseModel):
    title: Optional[str] = None
    crop: Optional[str] = None
    price: Optional[float] = None
    quantity: Optional[float] = None
    unit: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None

class ProductResponse(ProductBase):
    id: str
    farmer_id: str
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
