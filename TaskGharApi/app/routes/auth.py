# app/routes/auth.py
from fastapi import APIRouter, HTTPException, status
from app.models.user import UserRegisterSchema, UserLoginSchema
from app.database.connection import get_database
import bcrypt

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register_user(user_data: UserRegisterSchema):
    db = get_database()
    
    # Check if user already exists
    existing_user = await db.users.find_one({"email": user_data.email})
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email address is already registered."
        )
    
    # Save to MongoDB
    user_document = user_data.model_dump()
    user_document["password"] = hash_password(user_data.password)
    
    result = await db.users.insert_one(user_document)
    if result.inserted_id:
        return {"message": "User registered successfully on TaskGhar!"}
    
    raise HTTPException(status_code=500, detail="Failed to save user.")

@router.post("/login")
async def login_user(user_data: UserLoginSchema):
    db = get_database()
    user = await db.users.find_one({"email": user_data.email})
    
    if not user:
        raise HTTPException(status_code=400, detail="Invalid email or password")
        
    # Check encrypted password
    if bcrypt.checkpw(user_data.password.encode('utf-8'), user["password"].encode('utf-8')):
        return {
            "name": user["name"],
            "email": user["email"],
            "role": user["role"],
            "message": "Login successful!"
        }
        
    raise HTTPException(status_code=400, detail="Invalid email or password")