import sys
sys.path.append('C:/Users/Public/Documents/coding/KrishiMarket/backend')
from app.models import Base
print(Base.metadata.tables.keys())
