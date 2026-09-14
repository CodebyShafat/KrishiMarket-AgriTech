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
    "myProducts": "My Products",
    "addProduct": "Add Product",
    "editProduct": "Edit Product",
    "deleteProduct": "Delete Product",
    "productName": "Product Name",
    "category": "Category",
    "description": "Description",
    "quality": "Quality",
    "price": "Price",
    "quantity": "Quantity",
    "unit": "Unit",
    "location": "Location",
    "harvestDate": "Harvest Date",
    "available": "Available",
    "unavailable": "Unavailable",
    "saveProduct": "Save Product",
    "updateProduct": "Update Product",
    "cancel": "Cancel",
    "delete": "Delete",
    "confirm": "Confirm",
    "confirmDelete": "Are you sure you want to delete this product?",
    "noProducts": "No products listed yet",
    "productAdded": "Product added successfully",
    "productUpdated": "Product updated successfully",
    "productDeleted": "Product deleted successfully",
    "validationRequired": "This field is required",
    "validationNumeric": "Please enter a valid positive number",
    "edit": "Edit"
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
