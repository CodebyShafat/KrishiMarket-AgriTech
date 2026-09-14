import json
import glob
import os

new_keys = {
  "ai_ask_quantity": "How much quantity do you need?",
  "ai_ask_price": "What is your target price?",
  "ai_ask_crop": "Which crop are you looking for?",
  "ai_confirm_listing": "Please confirm if you want to create this listing.",
  "ai_confirm_order": "Please confirm if you want to place this order.",
  "ai_confirm_requirement": "Please confirm if you want to create this requirement.",
  "ai_confirm_offer": "Please confirm if you want to submit this offer.",
  "ai_greet": "Hello! How can I help you today?",
  "ai_network_error": "Network error. Please check your connection.",
  "ai_service_error": "AI service error. Please try again later.",
  "ai_parse_error": "I couldn't understand that. Please rephrase.",
  "ai_fallback_response": "I'm not sure how to help with that. Can you provide more details?",
  "ai_action_success": "Action completed successfully.",
  "ai_action_error": "Action failed to execute.",
  "ai_confirm_action": "Are you sure you want to proceed?"
}

arb_files = glob.glob('lib/l10n/*.arb')

for file in arb_files:
    with open(file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, val in new_keys.items():
        if key not in data:
            # We add English fallback for all, as real translations would be done by translators
            data[key] = val
            
    with open(file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
print("Added AI keys to all ARB files.")
