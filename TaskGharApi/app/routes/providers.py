# app/routes/providers.py
from fastapi import APIRouter, HTTPException, Query, Depends
from typing import List, Dict, Any
from app.database.connection import get_database # 🚀 Imports your real database connector

router = APIRouter(
    prefix="/providers",
    tags=["Providers Marketplace"]
)

@router.get("", response_model=List[Dict[str, Any]])
async def get_providers_by_category(category: str = Query(..., description="The service category to filter by")):
    """
    Fetches independent, skillful manpower live from the MongoDB database collection.
    """
    try:
        # 1. Connect to your live MongoDB database instance
        db = get_database()
        
        # 2. Target your 'users' or 'providers' collection
        # We search for users whose role is 'tasker' (or 'provider') and match the clicked category
        query = {
            "category": category,
            "role": "tasker"  # Ensures we only grab workforce accounts, not clients
        }
        
        # 3. Query MongoDB and convert the cursor results into a clean Python list
        cursor = db.users.find(query)
        real_workers = await cursor.to_list(length=100)
        
        # Clean up MongoDB '_id' ObjectIds so they transfer over the network as clean strings
        for worker in real_workers:
            if "_id" in worker:
                worker["_id"] = str(worker["_id"])
                
        return real_workers

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"MongoDB Platform Bridge Error: {str(e)}")