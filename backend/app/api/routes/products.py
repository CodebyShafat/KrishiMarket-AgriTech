from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uuid

from app.api.deps import get_db, get_current_user, require_role
from app.models.product import Product
from app.models.user import User
from app.schemas.product import ProductCreate, ProductUpdate, ProductResponse

router = APIRouter()

@router.post("", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_product(
    product_in: ProductCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("farmer"))
):
    if product_in.quantity < 0 or product_in.price < 0:
        raise HTTPException(status_code=400, detail="Invalid quantity or price")
        
    db_product = Product(
        id=str(uuid.uuid4()),
        farmer_id=str(current_user.id),
        title=product_in.title,
        crop=product_in.crop,
        price=product_in.price,
        quantity=product_in.quantity,
        unit=product_in.unit,
        description=product_in.description,
        image_url=product_in.image_url
    )
    db.add(db_product)
    await db.commit()
    await db.refresh(db_product)
    return db_product

@router.get("", response_model=List[ProductResponse])
async def list_products(
    crop: str = None,
    farmer_id: str = None,
    search: str = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    stmt = select(Product)
    if crop:
        stmt = stmt.where(Product.crop == crop)
    if farmer_id:
        stmt = stmt.where(Product.farmer_id == farmer_id)
    if search:
        stmt = stmt.where(Product.title.ilike(f"%{search}%"))
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    products = result.scalars().all()
    return products

@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: str,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: str,
    product_in: ProductUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("farmer"))
):
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    if product.farmer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to modify this product")
        
    update_data = product_in.model_dump(exclude_unset=True)
    if "quantity" in update_data and update_data["quantity"] < 0:
        raise HTTPException(status_code=400, detail="Invalid quantity")
    if "price" in update_data and update_data["price"] < 0:
        raise HTTPException(status_code=400, detail="Invalid price")
        
    for key, value in update_data.items():
        setattr(product, key, value)
        
    await db.commit()
    await db.refresh(product)
    return product

@router.delete("/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_product(
    product_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("farmer"))
):
    result = await db.execute(select(Product).where(Product.id == product_id))
    product = result.scalars().first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
        
    if product.farmer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to delete this product")
        
    await db.delete(product)
    await db.commit()
    return None
