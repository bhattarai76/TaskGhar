# app/database/connection.py
import os
from dotenv import load_dotenv  # ← Fixed line here!
from motor.motor_asyncio import AsyncIOMotorClient

# Search for and boot up the hidden .env file at the root level
load_dotenv()

# Safely extract the secret URL from the system environment
MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")

# Spin up our secure client engine channel
client = AsyncIOMotorClient(MONGO_URL)
database = client.taskghar_db

def get_database():
    return database