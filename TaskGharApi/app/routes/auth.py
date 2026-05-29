from fastapi import APIRouter, HTTPException, status
import os
import jwt
import bcrypt
from datetime import datetime, timedelta
from app.models.user import UserRegisterSchema, UserLoginSchema
from app.database.connection import get_database

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Read our secure configurations from the environment
SECRET_KEY = os.getenv("SECRET_KEY", "fallback_secret")
ALGORITHM = os.getenv("ALGORITHM", "HS256")

def hash_password(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

def create_access_token(data: dict) -> str:
    """Generate an encrypted digital ticket (JWT token) that expires."""
    to_encode = data.copy()
    # Set the token to expire 24 hours from right now
    expire = datetime.utcnow() + timedelta(minutes=1440)
    to_encode.update({"exp": expire})
    # Encode the payload into a secure string signed by our secret key
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

@router.post("/register", status_code=status.HTTP_201_CREATED)
async def register_user(user_data: UserRegisterSchema):
    db = get_database()
    existing_user = await db.users.find_one({"email": user_data.email})
    if existing_user:
        raise HTTPException(status_code=400, detail="An account with this email already exists.")
    
    new_user = {
        "name": user_data.name,
        "email": user_data.email,
        "password": hash_password(user_data.password),
        "role": user_data.role
    }
    result = await db.users.insert_one(new_user)
    return {"message": "Account created successfully!", "user_id": str(result.inserted_id)}

@router.post("/login", status_code=status.HTTP_200_OK)
async def login_user(login_data: UserLoginSchema):
    db = get_database()
    user = await db.users.find_one({"email": login_data.email})
    if not user or not bcrypt.checkpw(login_data.password.encode('utf-8'), user["password"].encode('utf-8')):
        raise HTTPException(status_code=401, detail="Invalid email or password.")
    
    # Generate the security token containing the user's data details
    token_payload = {
        "user_id": str(user["_id"]),
        "email": user["email"],
        "role": user["role"]
    }
    access_token = create_access_token(data=token_payload)
    
    # Send the digital ticket back to Flutter!
    return {
        "message": "Login successful!",
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "name": user["name"],
            "role": user["role"]
        }
    }