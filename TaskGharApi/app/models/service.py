from pydantic import BaseModel, Field

class ServiceCreateSchema(BaseModel):
    provider_id: str = Field(..., description="The unique database ID of the service provider")
    category: str = Field(..., description="e.g., Plumbing, Electrical, Cleaning, Painting")
    experience_years: int = Field(..., ge=0, description="Years of experience")
    hourly_rate: float = Field(..., gt=0, description="Rate per hour in NPR")
    location: str = Field(..., description="Specific area covered, e.g., Ghorahi, Tulsipur")
    is_available: bool = True

    class Config:
        json_schema_extra = {
            "example": {
                "provider_id": "66560a8b9c...",
                "category": "Electrical",
                "experience_years": 4,
                "hourly_rate": 500.0,
                "location": "Ghorahi",
                "is_available": True
            }
        }