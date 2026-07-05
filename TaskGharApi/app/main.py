from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.database.connection import get_database
from app.routes import services, bookings, providers 
from pydantic import BaseModel
import random
from bson import ObjectId 
from typing import Optional # 🚀 STEP 1: Added Optional import!

app = FastAPI(title="TaskGhar Hyperlocal API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(services.router)
app.include_router(bookings.router) 
app.include_router(providers.router) 

@app.get("/")
async def root():
    return {"status": "Online", "message": "Welcome to TaskGhar API!"}


# ==========================================
# 🚀 1. THE OTP VERIFICATION ENGINE
# ==========================================
otp_storage = {}

class VerificationRequest(BaseModel):
    contact_info: str  # This can be the Email OR Phone number

@app.post("/auth/send-verification")
async def send_verification(req: VerificationRequest):
    otp = str(random.randint(1000, 9999))
    otp_storage[req.contact_info] = otp
    
    print(f"\n" + "="*40)
    print(f"🔐 VERIFICATION CODE FOR {req.contact_info}:")
    print(f"Your TaskGhar code is {otp}")
    print("="*40 + "\n")
    
    return {"status": "success", "message": f"OTP sent to {req.contact_info}"}


# ==========================================
# 🚀 2. SECURE REGISTRATION & LOGIN
# ==========================================

# 🚀 STEP 2: Made email, phone, and tasker fields Optional with defaults!
class RegisterRequest(BaseModel):
    name: str
    email: Optional[str] = ""
    phone: Optional[str] = ""
    password: str
    role: str
    otp: str 
    category: Optional[str] = None
    rate: Optional[str] = None
    experience: Optional[str] = None

class LoginRequest(BaseModel):
    identifier: str  
    password: str

@app.post("/auth/register")
async def register_user(user: RegisterRequest):
    # 1. Security Check against whichever contact method they provided
    provided_contact = user.phone if user.phone else user.email
    if otp_storage.get(provided_contact) != user.otp:
        raise HTTPException(status_code=400, detail="Invalid Verification Code!")

    db = get_database()
    
    # 🚀 STEP 3: Smart duplicate check that ignores blank fields
    query_conditions = []
    if user.email != "": query_conditions.append({"email": user.email})
    if user.phone != "": query_conditions.append({"phone": user.phone})
    
    if query_conditions:
        existing_user = await db.users.find_one({"$or": query_conditions})
        if existing_user:
            raise HTTPException(status_code=400, detail="Account with this Email or Phone already exists!")

    # Save the new user
    new_user = user.dict()
    del new_user["otp"] 
    
    if new_user["role"] == "tasker":
        new_user["jobs"] = 0
        new_user["rating"] = 4.5
        new_user["status"] = "Available"
        new_user["verified"] = False

    await db.users.insert_one(new_user)
    
    # Clean up the used OTP
    if provided_contact in otp_storage:
        del otp_storage[provided_contact]
        
    return {"status": "success", "message": "Account created successfully!"}


@app.post("/auth/login")
async def login_user(req: LoginRequest):
    db = get_database()
    
    user = await db.users.find_one({
        "$or": [{"email": req.identifier}, {"phone": req.identifier}]
    })
    
    if not user or user.get("password") != req.password:
        raise HTTPException(status_code=401, detail="Invalid Email/Phone or Password")
        
    return {
        "name": user["name"], 
        "email": user.get("email", ""), 
        "phone": user.get("phone", ""),
        "role": user["role"]
    }

# ==========================================
# 🚀 3. BOOKING LOGIC
# ==========================================
class BookingRequest(BaseModel):
    expert_name: str
    service_type: str
    date: str
    address: str
    description: str
    status: str = "Pending"

@app.post("/bookings/create")
async def create_new_booking(booking: BookingRequest):
    db = get_database()
    result = await db.bookings.insert_one(booking.dict())
    return {"status": "success", "booking_id": str(result.inserted_id)}

@app.get("/bookings/{expert_name}")
async def get_expert_bookings(expert_name: str):
    db = get_database()
    bookings = await db.bookings.find({"expert_name": expert_name}).to_list(length=100)
    
    for booking in bookings:
        booking["_id"] = str(booking["_id"])
        
    return bookings

class StatusUpdateRequest(BaseModel):
    status: str

@app.put("/bookings/{booking_id}/status")
async def update_booking_status(booking_id: str, req: StatusUpdateRequest):
    db = get_database()
    
    result = await db.bookings.update_one(
        {"_id": ObjectId(booking_id)},
        {"$set": {"status": req.status}}
    )
    
    if result.modified_count == 1:
        return {"status": "success", "message": f"Job marked as {req.status}"}
    
    raise HTTPException(status_code=400, detail="Failed to update job")

# ==========================================

@app.get("/providers/{category}")
async def get_providers_by_category(category: str):
    db = get_database() 
    providers = await db.users.find({"role": "tasker", "category": category}, {"_id": 0, "password": 0}).to_list(length=100)
    return providers

    # ==========================================
# 🛡️ 4. ADMIN PORTAL ENDPOINTS
# ==========================================

@app.get("/admin/pending-taskers")
async def get_pending_taskers():
    """Fetches all taskers waiting for admin approval."""
    db = get_database()
    taskers = await db.users.find(
        {"role": "tasker", "verified": False},
        {"password": 0} # Never send passwords to frontend
    ).to_list(length=100)
    
    for t in taskers:
        t["_id"] = str(t["_id"])
    return taskers


class VerifyRequest(BaseModel):
    verified: bool

@app.put("/admin/verify-tasker/{user_id}")
async def verify_tasker(user_id: str, req: VerifyRequest):
    """Admin approves or revokes a tasker's verified badge."""
    db = get_database()
    result = await db.users.update_one(
        {"_id": ObjectId(user_id)},
        {"$set": {"verified": req.verified, "status": "Available" if req.verified else "Under Review"}}
    )
    
    if result.modified_count == 1:
        return {"status": "success", "message": "Tasker verification updated!"}
    raise HTTPException(status_code=400, detail="Failed to update verification status")


@app.get("/admin/metrics")
async def get_platform_metrics():
    """Returns high-level statistics for the admin dashboard overview."""
    db = get_database()
    total_customers = await db.users.count_documents({"role": "customer"})
    total_taskers = await db.users.count_documents({"role": "tasker"})
    total_bookings = await db.bookings.count_documents({})
    pending_bookings = await db.bookings.count_documents({"status": "Pending"})
    
    return {
        "customers": total_customers,
        "taskers": total_taskers,
        "total_jobs": total_bookings,
        "pending_jobs": pending_bookings
    }