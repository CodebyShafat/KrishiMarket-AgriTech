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
    "marketplace": "Marketplace",
    "searchProducts": "Search agricultural products",
    "search": "Search",
    "categories": "Categories",
    "nearbyProducts": "Nearby Products",
    "all": "All",
    "wheat": "Wheat",
    "rice": "Rice",
    "potato": "Potato",
    "onion": "Onion",
    "tomato": "Tomato",
    "vegetables": "Vegetables",
    "fruits": "Fruits",
    "pulses": "Pulses",
    "spices": "Spices",
    "other": "Other",
    "farmer": "Farmer",
    "farmerId": "Farmer ID",
    "sort": "Sort",
    "priceLowToHigh": "Price: Low to High",
    "priceHighToLow": "Price: High to Low",
    "nearest": "Nearest",
    "noProductsFound": "No products found",
    "clear": "Clear",
    "viewDetails": "View Details",
    "compare": "Compare",
    "comingSoon": "Coming Soon",
    "buyNow": "Buy Now (Coming Soon)",
    "customerHome": "Customer Home",
    "myOrders": "My Orders"
}

def main():
    for fpath in arb_files:
        if not os.path.exists(fpath):
            print(f"Skipping {fpath} (not found)")
            continue
            
        with open(fpath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        # Add new strings
        for k, v in new_strings.items():
            if k not in data:
                data[k] = v
                
        with open(fpath, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            
        print(f"Updated {fpath}")

if __name__ == "__main__":
    main()
