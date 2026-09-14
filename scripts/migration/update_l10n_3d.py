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
    "bulkRequirements": "Bulk Requirements",
    "myRequirements": "My Requirements",
    "createRequirement": "Create Requirement",
    "product": "Product",
    "requiredQuantity": "Required Quantity",
    "targetPrice": "Target Price",
    "deliveryLocation": "Delivery Location",
    "requiredBy": "Required By",
    "description": "Description",
    "offers": "Offers",
    "viewOffers": "View Offers",
    "submitOffer": "Submit Offer",
    "availableQuantity": "Available Quantity",
    "offeredPrice": "Offered Price",
    "quality": "Quality",
    "readyDate": "Ready Date",
    "farmerNote": "Farmer Note",
    "myOffers": "My Offers",
    "acceptOffer": "Accept Offer",
    "rejectOffer": "Reject Offer",
    "withdrawOffer": "Withdraw Offer",
    "acceptedQuantity": "Accepted Quantity",
    "remainingQuantity": "Remaining Quantity",
    "open": "Open",
    "partiallyFulfilled": "Partially Fulfilled",
    "fulfilled": "Fulfilled",
    "cancelled": "Cancelled",
    "expired": "Expired",
    "submitted": "Submitted",
    "shortlisted": "Shortlisted",
    "accepted": "Accepted",
    "rejected": "Rejected",
    "withdrawn": "Withdrawn",
    "priceLowToHigh": "Price: Low to High",
    "priceHighToLow": "Price: High to Low",
    "bestQuality": "Best Quality",
    "earliestReadyDate": "Earliest Ready Date",
    "noRequirements": "No requirements found",
    "noOffers": "No offers found",
    "confirm": "Confirm",
    "cancel": "Cancel",
    "save": "Save",
    "edit": "Edit",
    "category": "Category",
    "target": "Target",
    "publish": "Publish",
    "compareOffers": "Compare Offers",
    "buyer": "Buyer"
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
