from fastapi import APIRouter
from .endpoints import prices

router = APIRouter()
router.include_router(prices.router, tags=["Prices"])