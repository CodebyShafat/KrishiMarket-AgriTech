from fastapi import FastAPI
from app.core.config import settings
from app.api.routes import auth, products, bulk, orders, ai

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1)(:[0-9]+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
app.include_router(products.router, prefix=f"{settings.API_V1_STR}/products", tags=["products"])
app.include_router(bulk.router, prefix=f"{settings.API_V1_STR}/bulk", tags=["bulk"])
app.include_router(orders.router, prefix=f"{settings.API_V1_STR}/orders", tags=["orders"])
app.include_router(ai.router, prefix=f"{settings.API_V1_STR}/ai", tags=["ai"])

@app.get("/health")
async def health_check():
    return {"status": "ok", "message": "KrishiMarket backend is healthy"}
