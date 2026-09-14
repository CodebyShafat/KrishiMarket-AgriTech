from typing import List
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
import uuid

from app.api.deps import get_db, get_current_user, require_role
from app.models.product import Product
from app.models.order import Order, OrderItem
from app.models.user import User
from app.schemas.order import OrderCreate, OrderResponse, OrderItemResponse

router = APIRouter()

@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
async def create_order(
    order_in: OrderCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role(["retail_buyer", "bulk_buyer"]))
):
    if not order_in.items:
        raise HTTPException(status_code=400, detail="Order must contain at least one item")
        
    for item in order_in.items:
        if item.quantity <= 0:
            raise HTTPException(status_code=400, detail="Item quantity must be greater than zero")

    product_ids = [item.product_id for item in order_in.items]
    
    stmt = select(Product).where(Product.id.in_(product_ids)).with_for_update()
    result = await db.execute(stmt)
    products = {p.id: p for p in result.scalars().all()}
    
    if len(products) != len(set(product_ids)):
        raise HTTPException(status_code=404, detail="One or more products not found")
        
    total_amount = 0.0
    new_order_items = []
    order_id = str(uuid.uuid4())
    
    for item in order_in.items:
        product = products[item.product_id]
        if product.quantity < item.quantity:
            raise HTTPException(status_code=400, detail=f"Insufficient stock for product {product.id}")
            
        product.quantity -= item.quantity
        item_total = product.price * item.quantity
        total_amount += item_total
        
        new_order_item = OrderItem(
            id=str(uuid.uuid4()),
            order_id=order_id,
            product_id=product.id,
            quantity=item.quantity,
            price_at_time=product.price
        )
        new_order_items.append(new_order_item)
        
    new_order = Order(
        id=order_id,
        buyer_id=str(current_user.id),
        total_amount=total_amount,
        status="PLACED"
    )
    
    db.add(new_order)
    for oi in new_order_items:
        db.add(oi)
        
    await db.commit()
    await db.refresh(new_order)
    
    new_order.items = [] # We'll populate below if needed, but returning it is fine since it's just created.
    return new_order

@router.get("", response_model=List[OrderResponse])
async def list_orders(
    buyer_id: str = None,
    farmer_id: str = None,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    user_role = current_user.role.lower()
    
    if user_role in ["retail_buyer", "bulk_buyer"]:
        buyer_id = str(current_user.id)
    elif user_role == "farmer":
        farmer_id = str(current_user.id)
        
    stmt = select(Order)
    if buyer_id:
        stmt = stmt.where(Order.buyer_id == buyer_id)
    if farmer_id:
        stmt = stmt.join(OrderItem, OrderItem.order_id == Order.id).join(Product, Product.id == OrderItem.product_id).where(Product.farmer_id == farmer_id).distinct()
        
    stmt = stmt.offset(skip).limit(limit)
    result = await db.execute(stmt)
    orders = result.scalars().all()
    
    # Collect all product IDs to fetch them efficiently
    order_ids = [o.id for o in orders]
    if not order_ids:
        return []
        
    items_stmt = select(OrderItem).where(OrderItem.order_id.in_(order_ids))
    items_res = await db.execute(items_stmt)
    all_items = items_res.scalars().all()
    
    product_ids = [i.product_id for i in all_items]
    products_dict = {}
    farmers_dict = {}
    if product_ids:
        prod_stmt = select(Product).where(Product.id.in_(product_ids))
        prod_res = await db.execute(prod_stmt)
        products = prod_res.scalars().all()
        products_dict = {p.id: p for p in products}
        
        farmer_ids = [p.farmer_id for p in products]
        if farmer_ids:
            user_stmt = select(User).where(User.id.in_(farmer_ids))
            user_res = await db.execute(user_stmt)
            farmers = user_res.scalars().all()
            farmers_dict = {str(f.id): f.name for f in farmers}
    
    # Assemble response
    response_orders = []
    for order in orders:
        order_dict = {
            "id": order.id,
            "buyer_id": order.buyer_id,
            "total_amount": order.total_amount,
            "status": order.status,
            "created_at": order.created_at,
            "items": []
        }
        order_items = [i for i in all_items if i.order_id == order.id]
        for item in order_items:
            prod = products_dict.get(item.product_id)
            farmer_name = None
            prod_title = None
            unit = None
            farmer_id = None
            if prod:
                prod_title = prod.title
                unit = prod.unit
                farmer_id = str(prod.farmer_id)
                farmer_name = farmers_dict.get(farmer_id)
                
            # Security: If user is a farmer, only send them their own items
            if user_role == "farmer" and farmer_id != str(current_user.id):
                continue
                
            order_dict["items"].append(OrderItemResponse(
                id=item.id,
                order_id=item.order_id,
                product_id=item.product_id,
                quantity=item.quantity,
                price_at_time=item.price_at_time,
                product_name=prod_title,
                farmer_id=farmer_id,
                farmer_name=farmer_name,
                unit=unit
            ))
            
        if user_role == "farmer":
            order_dict["total_amount"] = sum(i.quantity * i.price_at_time for i in order_dict["items"])
            
        if order_dict["items"]:
            response_orders.append(OrderResponse(**order_dict))
        
    return response_orders

@router.delete("/{order_id}", status_code=status.HTTP_204_NO_CONTENT)
async def cancel_order(
    order_id: str,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_role(["retail_buyer", "bulk_buyer"]))
):
    result = await db.execute(select(Order).where(Order.id == order_id))
    order = result.scalars().first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
        
    if order.buyer_id != str(current_user.id):
        raise HTTPException(status_code=403, detail="Not authorized to cancel this order")
        
    if order.status != "PLACED":
        raise HTTPException(status_code=400, detail="Cannot cancel an order that is already being processed")
        
    order.status = "CANCELLED"
    
    items_res = await db.execute(select(OrderItem).where(OrderItem.order_id == order.id))
    items = items_res.scalars().all()
    
    product_ids = [item.product_id for item in items]
    if product_ids:
        stmt = select(Product).where(Product.id.in_(product_ids)).with_for_update()
        prod_res = await db.execute(stmt)
        products = {p.id: p for p in prod_res.scalars().all()}
        
        for item in items:
            if item.product_id in products:
                products[item.product_id].quantity += item.quantity
            
    await db.commit()
    return None
