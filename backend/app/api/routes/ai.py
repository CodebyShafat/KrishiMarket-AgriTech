from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import os
import json
from google import genai
from google.genai import types

from app.api.deps import get_current_user
from app.models.user import User

router = APIRouter()

class ChatMessage(BaseModel):
    role: str
    content: str

class AiChatRequest(BaseModel):
    text: str
    language: str
    context: Dict[str, Any]
    history: List[ChatMessage] = []

class AiChatResponse(BaseModel):
    intent: str
    entities: Dict[str, Any]
    missing_fields: List[str]
    requires_confirmation: bool
    response_key: str
    confidence_score: float

from app.core.config import settings

client = None
if settings.GEMINI_API_KEY and settings.GEMINI_API_KEY != "your_gemini_api_key_here" and settings.GEMINI_API_KEY.strip() != "":
    client = genai.Client(api_key=settings.GEMINI_API_KEY)

@router.post("/chat", response_model=AiChatResponse)
async def ai_chat(request: AiChatRequest, current_user: User = Depends(get_current_user)):
    if not client:
        raise HTTPException(status_code=500, detail="Gemini API key is not configured")

    role = current_user.role

    system_prompt = f"""
    You are an AI assistant for KrishiMarket, an agricultural marketplace.
    The current user is a '{role}'.
    
    You must extract the user's intent and parameters into a structured JSON response.
    
    Allowed intents: searchProduct, createProductListing, createBulkRequirement, unknown
    - Farmers can createProductListing.
    - Bulk Buyers can createBulkRequirement.
    - Anyone can searchProduct.
    - If a user tries an action they are not allowed to do, return "unknown" intent with "ai_action_error".
    
    Return a strict JSON object with this schema:
    {{
        "intent": "string",
        "entities": {{}},
        "missing_fields": ["string"],
        "requires_confirmation": boolean,
        "response_key": "string",
        "confidence_score": float
    }}
    
    If intent is createProductListing, entities should include: productName, quantity, price. If any are missing, add to missing_fields.
    If intent is createBulkRequirement, entities should include: productName, quantity.
    
    response_key should map to app localization keys like: ai_confirm_listing, ai_ask_quantity, ai_fallback_response.
    """

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=request.text,
            config=types.GenerateContentConfig(
                system_instruction=system_prompt,
                response_mime_type="application/json",
            )
        )
        
        data = json.loads(response.text)
        
        # Validation and fallback
        confidence = data.get("confidence_score", 1.0)
        if confidence < 0.6:
             return AiChatResponse(
                 intent="unknown",
                 entities={},
                 missing_fields=[],
                 requires_confirmation=False,
                 response_key="ai_fallback_response",
                 confidence_score=confidence
             )
             
        # Enforce role logic
        intent = data.get("intent", "unknown")
        if intent == "createProductListing" and role.lower() != "farmer":
             intent = "unknown"
             data["response_key"] = "ai_action_error"
        if intent == "createBulkRequirement" and role.lower() != "bulk buyer":
             intent = "unknown"
             data["response_key"] = "ai_action_error"

        return AiChatResponse(
            intent=intent,
            entities=data.get("entities", {}),
            missing_fields=data.get("missing_fields", []),
            requires_confirmation=data.get("requires_confirmation", False),
            response_key=data.get("response_key", "ai_action_success"),
            confidence_score=confidence
        )

    except Exception as e:
        import traceback
        err_msg = traceback.format_exc()
        print(f"Gemini API Error: {err_msg}")
        
        detail = "AI Service Error"
        if "429 RESOURCE_EXHAUSTED" in str(e):
            detail = "Rate limit exceeded. Please wait a moment and try again."
        elif "Gemini API key is not configured" in str(e):
            detail = "Gemini API key is not configured"
            
        raise HTTPException(status_code=500, detail=detail)
