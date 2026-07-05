# app/models/provider_db.py
from pydantic import BaseModel, Field
from typing import Optional

class ProviderDocument(BaseModel):
    name: str
    experience: str
    rating: float = 4.5
    jobs: int = 0
    rate: str  # e.g., "Rs. 500/hr"
    status: str = "Available"  # Available or Busy
    verified: bool = False
    category: str  # Plumbing, Electrical, etc.
    phone: str
    location: str  # e.g., "Ghorahi-15"

    class Config:
        json_schema_extra = {
            "example": {
                "name": "Ram Bahadur Thapa",
                "experience": "5 years",
                "category": "Plumbing",
                "rate": "500/hr",
                "phone": "9847800000",
                "location": "Ghorahi-15"
            }
        }