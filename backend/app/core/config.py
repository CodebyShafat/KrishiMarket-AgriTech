from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional

class Settings(BaseSettings):
    PROJECT_NAME: str = "KrishiMarket API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # Database
    DATABASE_URL: str
    
    # Auth / Secrets
    JWT_SECRET: str
    GEMINI_API_KEY: Optional[str] = None
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    ENVIRONMENT: str = "development" # 'development' or 'production'
    
    model_config = SettingsConfigDict(env_file=".env", env_ignore_empty=True, extra="ignore")

settings = Settings()
