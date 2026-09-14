from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime, timezone
import jwt

from app.api.deps import get_db, get_current_user
from app.schemas.user import UserCreate, UserResponse
from app.schemas.auth import Token, OTPRequest, OTPVerify, RefreshRequest
from app.models.user import User
from app.models.auth import RefreshToken
from app.services.auth_service import request_otp, verify_otp
from app.core.security import create_access_token, create_refresh_token, get_password_hash, verify_password
from app.core.config import settings

router = APIRouter()

@router.post("/request-otp")
async def request_otp_route(req: OTPRequest, db: AsyncSession = Depends(get_db)):
    # Note: real integration would send an SMS here if environment == production
    otp = await request_otp(req.phone_number, db)
    return {"message": "OTP sent successfully", "dev_otp": otp if settings.ENVIRONMENT == "development" else None}

@router.post("/verify-otp", response_model=Token)
async def verify_otp_route(req: OTPVerify, db: AsyncSession = Depends(get_db)):
    is_valid = await verify_otp(req.phone_number, req.otp, db)
    if not is_valid:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid or expired OTP")
        
    result = await db.execute(select(User).where(User.phone_number == req.phone_number))
    user = result.scalars().first()
    
    if not user:
        # Auto-register user with default profile details since OTP is valid
        hashed_pw = get_password_hash("mock_fallback")
        user = User(
            phone_number=req.phone_number,
            name="",
            role="",
            hashed_password=hashed_pw
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)
        
    access_token = create_access_token(user.id, user.role)
    refresh_token, exp = create_refresh_token(user.id)
    
    db_rt = RefreshToken(token=refresh_token, user_id=user.id, expires_at=exp)
    db.add(db_rt)
    await db.commit()
    
    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_in: UserCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.phone_number == user_in.phone_number))
    existing_user = result.scalars().first()
    
    hashed_pw = get_password_hash(user_in.password) if user_in.password else get_password_hash("mock_fallback")
    
    if existing_user:
        # Update existing skeleton user
        existing_user.name = user_in.name
        existing_user.role = user_in.role
        existing_user.hashed_password = hashed_pw
        await db.commit()
        await db.refresh(existing_user)
        return existing_user
        
    new_user = User(
        phone_number=user_in.phone_number,
        name=user_in.name,
        role=user_in.role,
        hashed_password=hashed_pw
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

@router.post("/refresh", response_model=Token)
async def refresh_token(req: RefreshRequest, db: AsyncSession = Depends(get_db)):
    try:
        payload = jwt.decode(req.refresh_token, settings.JWT_SECRET, algorithms=["HS256"])
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Invalid token")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
        
    # Replay/Revocation protection
    stmt = select(RefreshToken).where(
        RefreshToken.token == req.refresh_token,
        RefreshToken.revoked == False,
        RefreshToken.expires_at > datetime.now(timezone.utc)
    )
    result = await db.execute(stmt)
    db_token = result.scalars().first()
    
    if not db_token:
        raise HTTPException(status_code=401, detail="Refresh token revoked or invalid")
        
    user_result = await db.execute(select(User).where(User.id == int(user_id)))
    user = user_result.scalars().first()
    
    if not user:
        raise HTTPException(status_code=401, detail="User not found")
        
    # Rotate token
    db_token.revoked = True
    new_access = create_access_token(user.id, user.role)
    new_refresh, new_exp = create_refresh_token(user.id)
    
    new_db_rt = RefreshToken(token=new_refresh, user_id=user.id, expires_at=new_exp)
    db.add(new_db_rt)
    await db.commit()
    
    return {"access_token": new_access, "refresh_token": new_refresh, "token_type": "bearer"}

@router.post("/logout")
async def logout(req: RefreshRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(RefreshToken).where(RefreshToken.token == req.refresh_token))
    token = result.scalars().first()
    if token:
        token.revoked = True
        await db.commit()
    return {"message": "Successfully logged out"}

@router.get("/me", response_model=UserResponse)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user
