from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional

class BulkRequirementBase(BaseModel):
    crop: str
    required_quantity: float
    unit: str
    target_price: float

class BulkRequirementCreate(BulkRequirementBase):
    pass

class BulkRequirementUpdate(BaseModel):
    crop: Optional[str] = None
    required_quantity: Optional[float] = None
    unit: Optional[str] = None
    target_price: Optional[float] = None

class BulkRequirementResponse(BulkRequirementBase):
    id: str
    buyer_id: str
    fulfilled_quantity: float
    status: str
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)

class BulkOfferBase(BaseModel):
    requirement_id: str
    offered_quantity: float
    price: float

class BulkOfferCreate(BulkOfferBase):
    pass

class BulkOfferResponse(BulkOfferBase):
    id: str
    farmer_id: str
    status: str
    created_at: datetime
    
    model_config = ConfigDict(from_attributes=True)
