import os
import json

arb_files = [
    "lib/l10n/app_en.arb",
    "lib/l10n/app_hi.arb",
    "lib/l10n/app_bn.arb",
    "lib/l10n/app_mr.arb",
    "lib/l10n/app_te.arb",
    "lib/l10n/app_ta.arb",
    "lib/l10n/app_gu.arb",
    "lib/l10n/app_kn.arb",
    "lib/l10n/app_ml.arb",
    "lib/l10n/app_pa.arb",
    "lib/l10n/app_or.arb",
    "lib/l10n/app_as.arb"
]

new_strings = {
    "cart": "Cart",
    "myCart": "My Cart",
    "addToCart": "Add to Cart",
    "addedToCart": "Added to cart",
    "remove": "Remove",
    "quantity": "Quantity",
    "subtotal": "Subtotal",
    "total": "Total",
    "grandTotal": "Grand Total",
    "checkout": "Checkout",
    "orderSummary": "Order Summary",
    "placeOrder": "Place Order",
    "orderPlaced": "Order placed successfully",
    "orderId": "Order ID",
    "myOrders": "My Orders",
    "orderDetails": "Order Details",
    "placed": "Placed",
    "accepted": "Accepted",
    "preparing": "Preparing",
    "readyForPickup": "Ready for Pickup",
    "completed": "Completed",
    "cancelled": "Cancelled",
    "cancelOrder": "Cancel Order",
    "confirmCancellation": "Are you sure you want to cancel this order?",
    "continueShopping": "Continue Shopping",
    "viewMyOrders": "View My Orders",
    "customer": "Customer",
    "deliveryLocation": "Delivery Location",
    "paymentIntegrationComingSoon": "Payment integration coming soon",
    "emptyCart": "Your cart is empty",
    "noOrders": "No orders found",
    "status": "Status",
    "date": "Date",
    "items": "Items",
    "farmerOrders": "Farmer Orders",
    "updateStatus": "Update Status"
}

def main():
    for fpath in arb_files:
        if not os.path.exists(fpath):
            continue
        with open(fpath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for k, v in new_strings.items():
            if k not in data:
                data[k] = v
        with open(fpath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"Updated {fpath}")

if __name__ == "__main__":
    main()
