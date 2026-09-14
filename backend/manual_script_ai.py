import asyncio
from app.api.routes.ai import ai_chat, AiChatRequest
from app.models.user import User

async def run():
    req = AiChatRequest(text='I want to sell 50kg of potatoes', language='en', context={}, history=[])
    user = User(id='1', role='farmer')
    res = await ai_chat(req, user)
    print(res)

asyncio.run(run())
