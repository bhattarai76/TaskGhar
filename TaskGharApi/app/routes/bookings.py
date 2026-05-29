# app/routes/bookings.py
from fastapi import APIRouter, HTTPException, status
from app.models.booking import BookingCreateSchema, BookingUpdateStatusSchema
from app.database.connection import get_database
from bson import ObjectId

router = APIRouter(prefix="/bookings", tags=["Job Bookings"])

@router.post("/create", status_code=status.HTTP_201_CREATED)
async def create_booking(booking_data: BookingCreateSchema):
    db = get_database()
    
    # Verify the customer exists and check format
    try:
        customer = await db.users.find_one({"_id": ObjectId(booking_data.customer_id)})
        if not customer:
            raise HTTPException(status_code=400, detail="Customer account not found.")
            
        service = await db.services.find_one({"_id": ObjectId(booking_data.service_id)})
        if not service:
            raise HTTPException(status_code=400, detail="Service listing not found.")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ID format structure.")

    # Create the complete booking record
    new_booking = booking_data.model_dump()
    new_booking["status"] = "pending"  # All jobs start as pending
    
    result = await db.bookings.insert_one(new_booking)
    return {"message": "Job booked successfully!", "booking_id": str(result.inserted_id)}

@router.patch("/{booking_id}/status")
async def update_booking_status(booking_id: str, status_data: BookingUpdateStatusSchema):
    db = get_database()
    
    try:
        result = await db.bookings.update_one(
            {"_id": ObjectId(booking_id)},
            {"$set": {"status": status_data.status}}
        )
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Booking record not found.")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid booking ID format.")
        
    return {"message": f"Booking status updated to '{status_data.status}' successfully!"}