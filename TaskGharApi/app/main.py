from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # 1. Added this import line
from app.database.connection import get_database
from app.routes import auth, services, bookings 

app = FastAPI(title="TaskGhar Hyperlocal API", version="1.0.0")

# 2. Added this security rule block to open the network pipeline for Chrome
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows your Flutter Chrome web app to connect safely
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount all router systems
app.include_router(auth.router)
app.include_router(services.router)
app.include_router(bookings.router) 

@app.get("/")
async def root():
    return {"status": "Online", "message": "Welcome to TaskGhar Hyperlocal Service Platform API!"}

@app.get("/test-db")
async def test_db_connection():
    try:
        db = get_database()
        await db.command("ping")
        return {"database_status": "Connected Successfully to taskghar_db!"}
    except Exception as e:
        return {"database_status": "Failed to Connect", "error": str(e)}