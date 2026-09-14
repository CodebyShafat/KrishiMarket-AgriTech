from pydantic import BaseModel, ConfigDict
from datetime import datetime

class UserBase(BaseModel):
    phone_number: str
    name: str
    role: str

class UserCreate(UserBase):
    password: str | None = None

class UserResponse(UserBase):
    id: int
    created_at: datetime
    updated_at: datetime | None = None
    
    model_config = ConfigDict(from_attributes=True)
