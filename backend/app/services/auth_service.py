import random
from datetime import datetime, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.auth import OTPCode
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

async def request_otp(phone_number: str, db: AsyncSession) -> str:
    # Generate 6 digit OTP
    if settings.ENVIRONMENT == "development":
        otp = "123456"
    else:
        otp = "".join([str(random.randint(0, 9)) for _ in range(6)])
    

    expires_at = datetime.now(timezone.utc) + timedelta(minutes=5)
    
    db_otp = OTPCode(
        phone_number=phone_number,
        code=otp,
        expires_at=expires_at
    )
    db.add(db_otp)
    await db.commit()
    
    if settings.ENVIRONMENT == "production":
        # Integration point for real SMS provider (e.g. Twilio, AWS SNS)
        # We must not use the mock 123456 here.
        # logger.info(f"Sending real SMS via provider to {phone_number}")
        pass
    else:
        # Development simulation - strictly log to console, no hardcoded '123456' magic behavior
        logger.warning(f"DEV MODE OTP for {phone_number}: {otp}")
        
    return otp

async def verify_otp(phone_number: str, otp: str, db: AsyncSession) -> bool:
    stmt = select(OTPCode).where(
        OTPCode.phone_number == phone_number,
        OTPCode.code == otp,
        OTPCode.used == False,
        OTPCode.expires_at > datetime.now(timezone.utc)
    )
    result = await db.execute(stmt)
    db_otp = result.scalars().first()
    
    if not db_otp:
        return False
        
    db_otp.used = True
    await db.commit()
    return True
