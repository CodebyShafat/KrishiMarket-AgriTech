"""Normalize role names

Revision ID: ab342dd40ff6
Revises: 8c471c8f6218
Create Date: 2026-08-30 00:14:24.355331

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ab342dd40ff6'
down_revision: Union[str, None] = '8c471c8f6218'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("UPDATE users SET role = 'retail_buyer' WHERE LOWER(role) IN ('customer', 'retail buyer')")
    op.execute("UPDATE users SET role = 'bulk_buyer' WHERE LOWER(role) IN ('buyer', 'bulk buyer')")
    op.execute("UPDATE users SET role = 'farmer' WHERE LOWER(role) IN ('farmer')")

def downgrade() -> None:
    # It's a bit lossy to downgrade, but best effort:
    op.execute("UPDATE users SET role = 'customer' WHERE role = 'retail_buyer'")
    op.execute("UPDATE users SET role = 'buyer' WHERE role = 'bulk_buyer'")
    op.execute("UPDATE users SET role = 'FARMER' WHERE role = 'farmer'")
