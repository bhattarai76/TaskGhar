# app/models/booking.py
from pydantic import BaseModel, Field
from typing import Literal

class BookingCreateSchema(BaseModel):
    customer_id: str = Field(..., description="Database ID of the customer booking the service")
    service_id: str = Field(..., description="Database ID of the service listing being hired")
    booking_date: str = Field(..., description="Requested date/time for the job (e.g., 2026-06-01 10:00 AM)")
    address: str = Field(..., description="Customer's physical address for the service")

class BookingUpdateStatusSchema(BaseModel):
    status: Literal["pending", "accepted", "completed", "cancelled"]