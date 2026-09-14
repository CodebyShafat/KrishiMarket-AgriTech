from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uuid

from app.api.deps import get_db, get_current_user, require_role
from app.models.bulk import BulkRequirement, BulkOffer
from app.models.user import User
from app.schemas.bulk import (
    BulkRequirementCreate, BulkRequirementUpdate, BulkRequirementResponse,
    BulkOfferCreate, BulkOfferResponse
)

router = APIRouter()

# --- BULK REQUIREMENTS ---

@router.post("/requirements", response_model=BulkRequirementResponse, status_code=status.HTTP_201_CREATED)
async def create_requirement(
    req_in: BulkRequirementCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("bulk_buyer"))
):
    if req_in.required_quantity <= 0 or req_in.target_price < 0:
        raise HTTPException(status_code=400, detail="Invalid quantity or price")
        
    db_req = BulkRequirement(
        id=str(uuid.uuid4()),
        buyer_id=str(current_user.id),
        crop=req_in.crop,
        required_quantity=req_in.required_quantity,
        unit=req_in.unit,
        target_price=req_in.target_price,
        fulfilled_quantity=0.0,
        status="OPEN"
    )
    db.add(db_req)
    await db.commit()
    await db.refresh(db_req)
    return db_req

@router.get("/requirements", response_model=List[BulkRequirementResponse])
async def list_requirements(
    buyer_id: str = None,
    req_status: str = Query(None, alias="status"),
    crop: str = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    stmt = select(BulkRequirement)
    if buyer_id:
        stmt = stmt.where(BulkRequirement.buyer_id == buyer_id)
    if req_status:
        stmt = stmt.where(BulkRequirement.status == req_status)
    if crop:
        stmt = stmt.where(BulkRequirement.crop == crop)
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()

@router.get("/requirements/{req_id}", response_model=BulkRequirementResponse)
async def get_requirement(
    req_id: str,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(BulkRequirement).where(BulkRequirement.id == req_id))
    req = result.scalars().first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
    return req

@router.put("/requirements/{req_id}", response_model=BulkRequirementResponse)
async def update_requirement(
    req_id: str,
    req_in: BulkRequirementUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("bulk_buyer"))
):
    result = await db.execute(select(BulkRequirement).where(BulkRequirement.id == req_id))
    req = result.scalars().first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    if req.buyer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")
        
    update_data = req_in.model_dump(exclude_unset=True)
    if "required_quantity" in update_data:
        if update_data["required_quantity"] < req.fulfilled_quantity:
             raise HTTPException(status_code=400, detail="Cannot reduce required quantity below fulfilled quantity")
             
    for key, value in update_data.items():
        setattr(req, key, value)
        
    await db.commit()
    await db.refresh(req)
    return req

@router.delete("/requirements/{req_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_requirement(
    req_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("bulk_buyer"))
):
    result = await db.execute(select(BulkRequirement).where(BulkRequirement.id == req_id))
    req = result.scalars().first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    if req.buyer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized")
        
    if req.status != "OPEN" and req.fulfilled_quantity > 0:
        raise HTTPException(status_code=400, detail="Cannot delete requirement with accepted offers")
        
    # Check for accepted offers explicitly just in case
    offers_result = await db.execute(select(BulkOffer).where(BulkOffer.requirement_id == req_id, BulkOffer.status == "ACCEPTED"))
    if offers_result.scalars().first():
        raise HTTPException(status_code=400, detail="Cannot delete requirement with accepted offers")

    await db.delete(req)
    await db.commit()
    return None

# --- BULK OFFERS ---

@router.post("/offers", response_model=BulkOfferResponse, status_code=status.HTTP_201_CREATED)
async def create_offer(
    offer_in: BulkOfferCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("farmer"))
):
    req_result = await db.execute(select(BulkRequirement).where(BulkRequirement.id == offer_in.requirement_id))
    req = req_result.scalars().first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    if req.status == "FULFILLED":
        raise HTTPException(status_code=400, detail="Requirement already fulfilled")
        
    if offer_in.offered_quantity <= 0 or offer_in.price < 0:
        raise HTTPException(status_code=400, detail="Invalid quantity or price")
        
    db_offer = BulkOffer(
        id=str(uuid.uuid4()),
        requirement_id=offer_in.requirement_id,
        farmer_id=str(current_user.id),
        offered_quantity=offer_in.offered_quantity,
        price=offer_in.price,
        status="PENDING"
    )
    db.add(db_offer)
    await db.commit()
    await db.refresh(db_offer)
    return db_offer

@router.get("/offers", response_model=List[BulkOfferResponse])
async def list_offers(
    requirement_id: str = None,
    farmer_id: str = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    stmt = select(BulkOffer)
    if requirement_id:
        stmt = stmt.where(BulkOffer.requirement_id == requirement_id)
    if farmer_id:
        stmt = stmt.where(BulkOffer.farmer_id == farmer_id)
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()

@router.post("/offers/{offer_id}/accept", response_model=BulkOfferResponse)
async def accept_offer(
    offer_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("bulk_buyer"))
):
    # ATOMIC TRANSACTION FOR PARTIAL FULFILLMENT
    # 1. Begin transaction (SQLAlchemy async session manages this)
    # 2. Lock requirement
    
    # We first find the offer
    offer_res = await db.execute(select(BulkOffer).where(BulkOffer.id == offer_id))
    offer = offer_res.scalars().first()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
        
    if offer.status != "PENDING":
        raise HTTPException(status_code=400, detail="Offer is not in PENDING state")
        
    # Lock requirement using with_for_update() for Postgres concurrency
    stmt = select(BulkRequirement).where(BulkRequirement.id == offer.requirement_id).with_for_update()
    req_res = await db.execute(stmt)
    req = req_res.scalars().first()
    
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    if req.buyer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to accept this offer")
        
    remaining_quantity = req.required_quantity - req.fulfilled_quantity
    
    if offer.offered_quantity > remaining_quantity:
        raise HTTPException(status_code=400, detail="Offer exceeds remaining requirement quantity")
        
    # Process
    req.fulfilled_quantity += offer.offered_quantity
    if req.fulfilled_quantity >= req.required_quantity:
        req.status = "FULFILLED"
    else:
        req.status = "PARTIALLY_FULFILLED"
        
    offer.status = "ACCEPTED"
    
    await db.commit()
    await db.refresh(offer)
    return offer

@router.post("/offers/{offer_id}/reject", response_model=BulkOfferResponse)
async def reject_offer(
    offer_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role("bulk_buyer"))
):
    offer_res = await db.execute(select(BulkOffer).where(BulkOffer.id == offer_id))
    offer = offer_res.scalars().first()
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
        
    if offer.status != "PENDING":
        raise HTTPException(status_code=400, detail="Offer is not in PENDING state")
        
    req_res = await db.execute(select(BulkRequirement).where(BulkRequirement.id == offer.requirement_id))
    req = req_res.scalars().first()
    if not req:
        raise HTTPException(status_code=404, detail="Requirement not found")
        
    if req.buyer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to reject this offer")
        
    offer.status = "REJECTED"
    await db.commit()
    await db.refresh(offer)
    return offer
