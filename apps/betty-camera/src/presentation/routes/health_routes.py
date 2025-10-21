from fastapi import APIRouter, Response

health_router = APIRouter(tags=["health"])


@health_router.get("/health")
async def health_check():
    return {"status": "healthy", "service": "betty-camera"}
