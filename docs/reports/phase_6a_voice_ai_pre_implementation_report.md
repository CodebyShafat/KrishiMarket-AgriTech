# Phase 6A: Voice-Activated Vernacular AI - Pre-Implementation Report

## 1. EXISTING CODEBASE AUDIT

**Current State & Phase 6A Needs**
- **AiAssistantProvider / AiAssistantScreen**: Currently manages text-based AI state. Needs to integrate the VoiceInputService for speech-to-text input, switching state to 'listening' or 'processing'.
- **AiMessageEntity / AiIntent / AiActionResult / AiConversationState**: Currently structured for intent and entity extraction. Can be entirely reused. Will need UI localization for intent actions.
- **AiActionExecutor**: Executes intents post-confirmation. Can be reused completely.
- **MockAiAssistantRepository / ApiAiAssistantRepository**: Currently proxies requests to FastAPI or mocks them. Reusable, but needs to gracefully handle raw STT text instead of typed text.
- **VoiceInputService**: Currently a mock pipeline. Needs to be replaced/upgraded with a production STT provider.
- **FastAPI AI endpoint & Gemini integration**: Currently uses text prompts. Reusable. Will receive the transcribed text and return structured JSON intents/entities.
- **Marketplace Repositories & Backend APIs**: Reusable completely; no changes needed as AI interacts via `AiActionExecutor` after confirmation.

## 2. VOICE ARCHITECTURE

User
 ↓
Microphone (Flutter)
 ↓
Platform STT Service (On-device / Cloud STT)
 ↓
Transcript (Text)
 ↓
AI Assistant Provider (Flutter State)
 ↓
ApiAiAssistantRepository
 ↓
FastAPI AI Proxy (Backend)
 ↓
Gemini (LLM)
 ↓
Structured Intent JSON (Intent + Entities)
 ↓
Validation (Backend/Frontend)
 ↓
Confirmation UI (Flutter)
 ↓
AiActionExecutor (Flutter)
 ↓
Marketplace Repository
 ↓
FastAPI (Backend Marketplace APIs)
 ↓
PostgreSQL

**Responsibilities:**
- **Frontend (Flutter):** Audio capture, STT transcription, transcript preview/edit, triggering AI, displaying confirmation, and invoking the action executor.
- **Backend (FastAPI):** Relaying transcript to Gemini, enforcing prompt constraints, formatting structured output.
- **Gemini:** Extracting intents and entities from vernacular text.

## 3. SPEECH-TO-TEXT TECHNOLOGY DECISION

**Comparison:**
- **On-device speech recognition (speech_to_text package):** Low latency, free, offline capable. May lack robust support for all regional Indian languages.
- **Google Cloud Speech-to-Text API (via backend):** High accuracy for Indian languages, handles noisy environments well, but requires network, incurs cost, and adds latency.

**Recommendation:**
**Primary Approach:** Platform Speech Recognition (via `speech_to_text` Flutter package). It leverages Google Assistant's STT on Android and Siri on iOS, which both have excellent and constantly improving support for Indian languages without incurring direct API costs to the project.
**Fallback Approach:** If platform STT is unavailable, fallback to manual text input.

## 4. 12-LANGUAGE SUPPORT

- The selected `AppLanguage` will map directly to the `speech_to_text` locale ID.
- The transcribed text will be sent to Gemini along with a system prompt indicating the language: "The user is speaking in {Language}."
- Responses and missing information prompts will be returned in the selected language.

**Language Code Mapping Table:**
- Assamese: `as-IN`
- Bengali: `bn-IN`
- Gujarati: `gu-IN`
- Hindi: `hi-IN`
- Kannada: `kn-IN`
- Malayalam: `ml-IN`
- Marathi: `mr-IN`
- Odia: `or-IN`
- Punjabi: `pa-IN`
- Tamil: `ta-IN`
- Telugu: `te-IN`
- English: `en-IN`

## 5. VERNACULAR EXAMPLES

**Hindi (Create Listing):**
"मुझे 500 किलो आलू ₹30 किलो में बेचना है" -> `intent: createProductListing`, `entities: {product: potato, quantity: 500, unit: kg, price: 30}`. Missing Info: NO. Confirmation: YES.

**Bengali (Product Search):**
"আমি ১০ বস্তা চাল কিনতে চাই" -> `intent: searchProduct`, `entities: {product: rice, quantity: 10, unit: bags}`. Missing Info: NO. Confirmation: NO.

**Tamil (Price Query):**
"இன்று தக்காளி விலை என்ன?" -> `intent: generalQuestion`, `entities: {topic: price, product: tomato}`. Missing Info: NO. Confirmation: NO.

## 6. STRUCTURED AI OUTPUT

**JSON Contract:**
```json
{
  "intent": "createProductListing",
  "entities": {
    "productName": "wheat",
    "quantity": 500,
    "unit": "kg",
    "price": 30
  },
  "missing_fields": [],
  "requires_confirmation": true,
  "language": "hi",
  "confidence": 0.95,
  "message_key": "ai_confirm_listing"
}
```
- Unknown intents fallback to `unknown` with a clarification `message_key`.
- Gemini output is parsed securely; missing or malformed JSON triggers an error state.

## 7. SECURITY ARCHITECTURE

- **Gemini API Key:** Stored securely in backend environment variables. Flutter never sees it.
- **Authentication:** Flutter passes standard JWT to FastAPI. FastAPI proxy verifies JWT before calling Gemini.
- **Abuse Protection:** FastAPI enforces rate limits (e.g., 10 AI requests per minute per user) to prevent quota exhaustion and abuse.

## 8. AI SAFETY

- **Enforcement:** Gemini's role is strictly NLU (Natural Language Understanding). It returns JSON. It has no database access.
- The Flutter `AiAssistantProvider` receives the JSON. If `requires_confirmation` is true, it halts and presents a UI confirmation card. Only when the user taps "Confirm", the `AiActionExecutor` is invoked with the user's JWT credentials to call the actual marketplace API.

## 9. ACTION TYPES

- **Search Products:** All Roles | Entities: Product | Conf: No | Endpoint: `/products/search` | Phase 6A: Add STT trigger.
- **Create Product Listing:** Farmer | Entities: Name, Qty, Price | Conf: Yes | Endpoint: `/products/` | Phase 6A: Extract entities from STT.
- **Create Bulk Requirement:** Bulk Buyer | Entities: Name, Qty, Target Price | Conf: Yes | Endpoint: `/bulk/` | Phase 6A: Extract entities from STT.

## 10. ERROR HANDLING

- **Microphone Denied:** Show localized UI explaining why mic access is needed with a button to open settings.
- **STT Timeout / No Speech:** Localized toast: "We didn't catch that. Please try again."
- **Malformed Gemini JSON:** Fallback to safe error: "I'm having trouble understanding right now."

## 11. PERMISSION HANDLING

- Android: `<uses-permission android:name="android.permission.RECORD_AUDIO" />` in `AndroidManifest.xml`.
- iOS: `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` in `Info.plist`.
- We will use the `permission_handler` package to request and check status before initializing STT.

## 12. UI/UX DESIGN

- **Idle:** Floating Action Button (FAB) with a Microphone icon.
- **Listening:** FAB expands, turns red, shows an animated waveform, and a recording timer.
- **Preview:** Once STT stops, the transcribed text appears in the chat bubble for 2 seconds (with an edit pencil icon) before auto-sending.
- **Confirmation:** A structured card (e.g., "Sell 500kg Wheat at ₹30?") with Green (Confirm) and Red (Cancel) buttons.

## 13. ACCESSIBILITY

- Large, high-contrast microphone button.
- Haptic feedback when listening starts and stops.
- Color-independent confirmation buttons (using clear icons like Check/Cross).
- Simple, localized text to accommodate low-literacy users.

## 14. BACKEND AUDIO ARCHITECTURE

**Recommendation:** Option B - Convert to text on-device and only send transcript to backend.
**Reason:** 
- Drastically reduces bandwidth, crucial for rural farmers with 2G/3G connectivity.
- Significantly lowers latency and server costs (no audio processing on our backend).
- Enhances SIH demo reliability since text payloads are tiny and fast.

## 15. DATABASE IMPACT

**Recommendation:** No database changes are needed for Phase 6A.
- Intents map to existing actions. Transcripts are transient and treated like normal text inputs. AI interactions do not require persistent logs for MVP.

## 16. TESTING STRATEGY

- **Unit:** Test `AppLanguage` to STT Locale mapping. Test JSON parsing of Gemini output.
- **Integration:** Mock STT output -> send to FastAPI -> verify returned JSON -> verify confirmation UI appears.
- **Security:** Ensure direct API calls without confirmation fail.

## 17. MOCK / DEVELOPMENT MODE

- `USE_API_BACKEND=false` will use `MockVoiceInputService`.
- Pressing the microphone will simulate a hardcoded transcription (e.g., "I want to sell wheat") after 2 seconds to test the pipeline without needing real audio input.

## 18. SIH DEMO FLOW

1. Farmer selects **Hindi**.
2. Presses microphone, UI shows listening waveform.
3. Says: "मेरे पास 500 किलो गेहूं है, इसे 30 रुपये किलो में बेचना है"
4. Transcript appears in chat: "मेरे पास 500 किलो..."
5. AI processes and shows a Confirmation Card: "Listing: Wheat, 500kg, ₹30/kg".
6. Farmer presses **Confirm**.
7. App transitions to the Marketplace view showing the newly created listing.

## 19. PERFORMANCE TARGETS

- Mic Startup: < 0.5s
- STT Latency: Real-time text streaming
- AI Response: < 2.0s
- Confirmation to Action: < 1.0s
- Total time (speech end to confirmation): < 2.5s (Acceptable for SIH).

## 20. OFFLINE COMPATIBILITY

- STT interface `VoiceInputService` is abstract. In Phase 6D, we can swap the implementation to a fully offline on-device STT model without changing the UI or AI provider logic, though LLM capabilities would still require network unless an offline LLM is introduced.

## 21. FILE-BY-FILE IMPLEMENTATION PLAN

- `lib/features/ai_assistant/domain/repositories/voice_input_service.dart` (MODIFIED): Define STT methods.
- `lib/features/ai_assistant/data/repositories/prod_voice_input_service.dart` (CREATED): Implements `speech_to_text`.
- `lib/features/ai_assistant/presentation/providers/ai_assistant_provider.dart` (MODIFIED): Wire STT service to chat flow.
- `lib/features/ai_assistant/presentation/pages/ai_assistant_screen.dart` (MODIFIED): Add Mic UI and permissions logic.

## 22. DEPENDENCY PLAN

- `speech_to_text`: For on-device and platform speech recognition. (Android/iOS supported). Alternative: Google Cloud STT API.
- `permission_handler`: For cross-platform microphone permission requests.

## 23. MIGRATION / ROLLBACK PLAN

- Implement `ProdVoiceInputService` behind a DI toggle or feature flag (`USE_REAL_VOICE=true`).
- If STT fails, simply disable the feature flag and fall back to `MockVoiceInputService` and text input. No breaking changes to existing AI chat.

## 24. RISKS

- **HIGH:** Indian language STT accuracy (Mitigation: Allow manual text editing of transcript).
- **HIGH:** Network latency for Gemini (Mitigation: Show clear loading states).
- **MEDIUM:** Gemini hallucination (Mitigation: Strict JSON schema and mandatory user confirmation).
- **LOW:** Microphone permissions denied (Mitigation: Clear UX explanation).

## 25. SIH VALUE

Typical marketplace: User navigates forms, dropdowns, and typing.
KrishiMarket: User speaks naturally in their regional language -> AI understands -> AI prepares action -> User confirms -> Real marketplace transaction.
This demonstrates high technical complexity (AI + Vernacular + Mobile) solving a real-world accessibility problem for low-literacy farmers, making it highly demo-able and impactful.

## 26. FINAL RECOMMENDATION

- **STT Architecture:** On-device Platform STT (Option B)
- **Backend:** FastAPI Proxy enforcing JSON schema
- **Flutter:** `speech_to_text` + `AiAssistantProvider`
- **Security:** Gemini API keys strictly server-side
- **Database Changes:** None
- **Dependencies:** `speech_to_text`, `permission_handler`

## APPROVAL CHECKLIST

- [ ] Architecture approved
- [ ] STT strategy approved
- [ ] Security approved
- [ ] Localization strategy approved
- [ ] UI/UX approved
- [ ] Backend design approved
- [ ] Testing strategy approved
- [ ] SIH demo flow approved
- [ ] Ready for implementation
