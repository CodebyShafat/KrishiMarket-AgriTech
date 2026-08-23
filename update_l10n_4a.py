import os
import json

arb_files = [
    'app_en.arb', 'app_hi.arb', 'app_bn.arb', 'app_mr.arb', 
    'app_te.arb', 'app_ta.arb', 'app_gu.arb', 'app_kn.arb', 
    'app_ml.arb', 'app_pa.arb', 'app_or.arb', 'app_as.arb'
]

strings = {
    'aiAssistant': 'AI Assistant',
    'askMeAnything': 'Ask me anything...',
    'listening': 'Listening...',
    'stopListening': 'Stop Listening',
    'send': 'Send',
    'clearConversation': 'Clear Conversation',
    'thinking': 'Thinking...',
    'somethingWentWrong': 'Something went wrong. Please try again.',
    'tryAgain': 'Try Again',
    'confirm': 'Confirm',
    'cancel': 'Cancel',
    'findProducts': 'Find Products',
    'myCart': 'My Cart',
    'myOrders': 'My Orders',
    'comparePrices': 'Compare Prices',
    'myProducts': 'My Products',
    'findBulkRequirements': 'Find Bulk Requirements',
    'createListing': 'Create Listing',
    'createRequirement': 'Create Requirement',
    'myRequirements': 'My Requirements',
    'viewOffers': 'View Offers',
    'actionNeedsConfirmation': 'Please confirm this action.',
    'actionNeedsMoreInformation': 'I need more information to proceed.',
    'actionSuccess': 'Action completed successfully.',
    'actionError': 'Could not complete the action.'
}

# Provide simple mapped translations for Hindi as a representative alternative, fallback to EN otherwise (mock only)
hindi_translations = {
    'aiAssistant': 'एआई सहायक',
    'askMeAnything': 'मुझसे कुछ भी पूछें...',
    'listening': 'सुन रहा हूँ...',
    'stopListening': 'सुनना बंद करें',
    'send': 'भेजें',
    'clearConversation': 'बातचीत साफ़ करें',
    'thinking': 'सोच रहा हूँ...',
    'somethingWentWrong': 'कुछ गलत हो गया। कृपया पुन: प्रयास करें।',
    'tryAgain': 'पुन: प्रयास करें',
    'confirm': 'पुष्टि करें',
    'cancel': 'रद्द करें',
    'findProducts': 'उत्पाद खोजें',
    'myCart': 'मेरी कार्ट',
    'myOrders': 'मेरे ऑर्डर',
    'comparePrices': 'कीमतों की तुलना करें',
    'myProducts': 'मेरे उत्पाद',
    'findBulkRequirements': 'थोक आवश्यकताएँ खोजें',
    'createListing': 'लिस्टिंग बनाएँ',
    'createRequirement': 'आवश्यकता बनाएँ',
    'myRequirements': 'मेरी आवश्यकताएँ',
    'viewOffers': 'प्रस्ताव देखें',
    'actionNeedsConfirmation': 'कृपया इस कार्रवाई की पुष्टि करें।',
    'actionNeedsMoreInformation': 'आगे बढ़ने के लिए मुझे और जानकारी चाहिए।',
    'actionSuccess': 'कार्रवाई सफलतापूर्वक पूरी हुई।',
    'actionError': 'कार्रवाई पूरी नहीं हो सकी।'
}

base_dir = r"lib\l10n"

def update_arbs():
    for filename in arb_files:
        filepath = os.path.join(base_dir, filename)
        if not os.path.exists(filepath):
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        is_hindi = (filename == 'app_hi.arb')
        
        for key, en_val in strings.items():
            if key not in data:
                if is_hindi and key in hindi_translations:
                    data[key] = hindi_translations[key]
                else:
                    data[key] = en_val
                    
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"Updated {filename}")

if __name__ == '__main__':
    update_arbs()
