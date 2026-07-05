# app/models/user.py
from pydantic import BaseModel, EmailStr
from typing import Optional

class UserRegisterSchema(BaseModel):
    name: str
    email: EmailStr
    password: str
    role: str  # This will be either "customer" or "tasker"
    
    # Optional fields needed ONLY if role is "tasker"
    category: Optional[str] = None
    rate: Optional[str] = None
    experience: Optional[str] = None
    status: Optional[str] = "Available"
    jobs: Optional[int] = 0
    rating: Optional[float] = 4.5
    verified: Optional[bool] = False

class UserLoginSchema(BaseModel):
    email: EmailStr
    password: str