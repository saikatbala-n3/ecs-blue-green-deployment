import os
import logging
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="ECS Blue-Green API", version="1.0.0")


class HealthResponse(BaseModel):
    """ALB health check response."""

    status: str
    version: str
    timestamp: str


class ItemCreate(BaseModel):
    """Request schema for creating items."""

    name: str
    description: str


class ItemResponse(BaseModel):
    """Response schema foir item operations."""

    id: int
    name: str
    description: str
    created_at: str


items: list[dict] = []
counter = 0


@app.get("/health", response_model=HealthResponse, status_code=status.HTTP_200_OK)
def health_check():
    """Health check endpoint for ALB taget group."""

    return HealthResponse(
        status="healthy",
        version=os.environ.get("APP_VERSION", "unknown"),
        timestamp=datetime.now(timezone.utc).isoformat() + "Z",
    )


@app.get("/")
def root():
    return {
        "message": "ECS Blue-Green Deployment API",
        "version": os.environ.get("APP_VERSION", "unknown"),
    }


@app.post("/items", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
def create_item(item: ItemCreate):
    """Create new item."""
    global counter
    counter += 1
    new_item = {
        "id": counter,
        "name": item.name,
        "description": item.description,
        "created_at": datetime.now(timezone.utc).isoformat() + "Z",
    }
    items.append(new_item)
    logger.info(f"Created item: {new_item[id]}")
    return new_item


@app.get("/items", response_model=list[ItemResponse])
def list_items():
    """List of all items."""
    return items


@app.get("/items/{item_id}", response_model=ItemResponse)
def get_item(item_id):
    """Get single item by ID."""
    for item in items:
        if item["id"] == item_id:
            return item
    raise HTTPException(status_code=404, detail="Item not found")
