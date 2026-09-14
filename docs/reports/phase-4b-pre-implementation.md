# Phase 4B Pre-Implementation Report: Production Gemini AI Integration

## 1. Architectural Approach
We will preserve the existing clean architecture established in Phases 1-4A. 
- **`AiAssistantRepository`**: We will introduce `GeminiAiAssistantRepository` implementing this interface. The mock implementation will be kept for testing/fallback.
- **`AiActionExecutor`**: We will keep the executor responsible for database/state modifications, entirely isolated from the AI layer.
- **Strict Role Separation**: The Gemini model will be strictly limited to **Natural Language Understanding (NLU)**—identifying intents, extracting entities, and determining conversation state. It will **never** have direct access to our repositories or databases.

## 2. Structured NLU Output (No Free-form Text)
To prevent hallucinations and guarantee safety, we will instruct Gemini (via System Instructions and `responseSchema` or function calling) to return structured JSON instead of conversational text.

The JSON schema will look like this:
```json
{
  "intent": "createProductListing",
  "entities": { "crop": "Wheat", "quantity": 50 },
  "missing_information": ["price"],
  "response_key": "ai_ask_price",
  "requires_confirmation": false
}
```

## 3. Localization and Multi-Language Support
- The user can type in English, Hindi, or Hinglish. Gemini natively understands these.
- **No Hardcoded AI Text**: Instead of letting Gemini generate the response text in Hindi/English, Gemini will return a predefined **`response_key`** (e.g., `ai_ask_price`). 
- The Flutter client will use `AppLocalizations.of(context)` to resolve this key into the correct language string, ensuring the app's tone is consistent and fully controlled by our ARB files.

## 4. Mandatory Confirmation & Missing Information
- **Missing Information**: If Gemini detects an intent (e.g., `createProductListing`) but mandatory entities (like price or quantity) are missing, it will return the `missing_information` array and an appropriate `response_key`. The repository updates the `AiConversationState` to prompt the user.
- **Mandatory Confirmation**: For any state-changing intent (create listing, place order), once all entities are collected, Gemini will return `requires_confirmation: true`. The UI will render a specific confirmation widget. The `AiActionExecutor` is only triggered if the user explicitly presses "Confirm".

## 5. Security & API Key Management
- The Gemini API key will **not** be hardcoded. 
- It will be loaded via a `.env` file using `flutter_dotenv`.
- The repository will be designed so the `google_generative_ai` client can easily be swapped to point to a custom base URL (e.g., a FastAPI backend proxy) in the future without changing the repository logic.

## 6. Error Handling
- We will implement a robust `try-catch` wrapper around the Gemini API call.
- We will handle:
  - `SocketException` (Network failures) -> localized network error message.
  - `GenerativeAIException` (API limits, safety blocks) -> localized service error.
  - `FormatException` (Invalid JSON returned by Gemini) -> fallback error message.
  - Timeouts.

## Proposed Steps for Implementation
1. Add `google_generative_ai` and `flutter_dotenv` to `pubspec.yaml`.
2. Update `.arb` files with required AI conversational strings in English and Hindi.
3. Create `GeminiAiAssistantRepository` implementing the structured JSON NLU prompt.
4. Update `AiAssistantProvider` to use the new repository.
5. Enhance `AiActionExecutor` to handle the actual state-changing domain logic.
6. Update the `AiAssistantScreen` to render confirmation prompts when `requires_confirmation` is true.

**Please review this report. Click "Proceed" if you want me to start the implementation.**
