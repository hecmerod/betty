"""
Health check endpoint para monitoreo de Docker
"""
from fastapi import APIRouter

health_router = APIRouter()

@health_router.get("/health")
async def health_check():
    """Endpoint de health check para Docker"""
    return {"status": "healthy", "service": "betty-camera"}


