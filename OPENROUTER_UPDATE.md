# v1.4.0 - OpenRouter Update (sk-or-v1-... support)

## What's New
- **Unified AI Service**: `gemini_service.dart` now auto-detects key type
  - `sk-or-v1-...` / `sk-or-...` -> OpenRouter (GPT-4o, Claude 3.5, Gemini 2.0 via one key)
  - `AIza...` -> Google Gemini direct
- **OpenRouter Model**: Default `openai/gpt-4o-mini` (fast, cheap, good for study). Can change to `anthropic/claude-3.5-sonnet` or `google/gemini-2.0-flash-001` in code.
- **Settings Screen**: Now shows OpenRouter + Gemini options, detects key type, shows active provider badge
- **Tutor Screen**: Shows "OpenRouter GPT-4o" chip when using OpenRouter key
- **Exam Answer, Vocab, Quiz screens**: Work with both keys automatically (same GeminiService)
- **New File**: `lib/services/openrouter_service.dart` - dedicated service if you want to use directly

## Your Key
You provided an OpenRouter key (sk-or-v1-...) - supports 300+ models.
Key format: sk-or-v1-... from https://openrouter.ai/keys

**How to use in app:**
1. Open app -> Settings
2. Paste key `sk-or-v1-...` -> Save
3. AI Tutor, Exam Writer, Vocab, Quiz AI will all use GPT-4o-mini via OpenRouter
4. No need for separate Gemini key anymore, but Gemini still works if you paste AIza...

**Security:**
- Key stored only on device via SharedPreferences
- Never uploaded, only sent to https://openrouter.ai/api/v1/chat/completions
- For APK build, key is NOT baked into APK - each user enters own key

## How to pre-fill key in APK (optional, for your own build)
If you want APK with key pre-filled (not recommended for public repo due to secret scanning):
- Use --dart-define=OPENROUTER_KEY=sk-or-v1-...
- Better: Keep as Settings entry, user pastes.

Built with Flutter
Updated via AI Super Agent
