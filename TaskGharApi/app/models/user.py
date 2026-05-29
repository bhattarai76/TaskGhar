from pydantic import BaseModel, EmailStr, Field
from typing import Literal

class UserRegisterSchema(BaseModel):
    # Validates that full name is a string and trims whitespace
    name: str = Field(..., min_length=2, max_length=50)
    
    # Validates proper email format (e.g., example@domain.com)
    email: EmailStr
    
    # Validates that the password is safe and at least 6 characters long
    password: str = Field(..., min_length=6)
    
    # Restricts account types exclusively to 'customer' or 'provider'
    role: Literal["customer", "provider"]

    class Config:
        json_schema_extra = {
            "example": {
                "name": "Ram Bahadur",
                "email": "ram@taskghar.com",
                "password": "securepassword123",
                "role": "customer"
            }
        }
        

class UserLoginSchema(BaseModel):
    email: EmailStr
    password: str

    class Config:
        json_schema_extra = {
            "example": {
                "email": "ram@taskghar.com",
                "password": "securepassword123"
            }
        }
        