from fastapi import APIRouter, HTTPException, status
from app.models.service import ServiceCreateSchema
from app.database.connection import get_database
from bson import ObjectId

router = APIRouter(prefix="/services", tags=["Marketplace Services"])

@router.post("/create", status_code=status.HTTP_201_CREATED)
async def create_service_listing(service_data: ServiceCreateSchema):
    db = get_database()
    try:
        provider = await db.users.find_one({"_id": ObjectId(service_data.provider_id)})
        if not provider or provider["role"] != "provider":
            raise HTTPException(status_code=400, detail="Invalid provider ID. User must be registered as a provider.")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid ID format structure.")

    new_listing = service_data.model_dump()
    result = await db.services.insert_one(new_listing)
    return {"message": "Service listing published successfully!", "listing_id": str(result.inserted_id)}

@router.get("/search")
async def search_services(category: str = None, location: str = None):
    db = get_database()
    query = {}
    if category:
        query["category"] = {"$regex": category, "$options": "i"}
    if location:
        query["location"] = {"$regex": location, "$options": "i"}
        
    cursor = db.services.find(query)
    listings = []
    async for doc in cursor:
        doc["_id"] = str(doc["_id"])
        listings.append(doc)
    return listings