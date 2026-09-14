from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.sql import func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.ext.compiler import compiles
import sqlalchemy.types as types
from app.db.database import Base

# Fallback for SQLite when JSONB isn't available
class JSONType(types.TypeDecorator):
    impl = types.JSON
    cache_ok = True

    def load_dialect_impl(self, dialect):
        if dialect.name == 'postgresql':
            return dialect.type_descriptor(JSONB())
        else:
            return dialect.type_descriptor(types.JSON())

class AIConversation(Base):
    __tablename__ = "ai_conversations"

    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, nullable=False, index=True)
    context_data = Column(JSONType, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class AIMessage(Base):
    __tablename__ = "ai_messages"

    id = Column(String, primary_key=True, index=True)
    conversation_id = Column(String, ForeignKey("ai_conversations.id"), nullable=False)
    role = Column(String, nullable=False)
    content = Column(String, nullable=False)
    intent = Column(String, nullable=True)
    parameters = Column(JSONType, nullable=True)
    requires_confirmation = Column(Boolean, default=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
