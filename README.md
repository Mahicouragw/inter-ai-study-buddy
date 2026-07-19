# 📚 Inter AI Study Buddy

**AI-powered study companion for Telangana Intermediate students**
(CEC stream + Languages — English Medium, Inter 1st & 2nd Year)

Built with **Flutter** (Android) + optional **Google Gemini (free tier)** for live AI features.
All six subjects included: **Economics, Commerce, Civics, Accountancy, English, తెలుగు** — with official free Govt. of Telangana textbook PDFs linked inside the app.

---

## ✨ Features

| # | Feature | Works Offline? |
|---|---------|----------------|
| 1 | 📘 Subject browser — units & quick-revision key points | ✅ |
| 2 | ❓ Question bank — **2-mark, 5-mark, 10-mark** model Q&A per subject (60+ per subject) | ✅ |
| 3 | 🎯 **Quizzes** — MCQ quizzes per subject with explanations, scoring & best-score tracking | ✅ |
| 4 | ✨ **AI question generator** — creates 5 fresh quiz questions on demand (Gemini) | 🔑 |
| 5 | 🤖 **AI Tutor chat** — ask any doubt, step-by-step answers | 🔑 |
| 6 | 🧒 **ELI5 mode** — "Explain Like I'm 5" with fun everyday examples | 🔑 |
| 7 | 🎤 **Talk to the tutor** — speak doubts via mic (speech-to-text) | ✅ / 🔑 |
| 8 | 🔊 **Hear answers** — text-to-speech reads tutor replies aloud | ✅ / 🔑 |
| 9 | ✍️ **Exam Answer Writer** — pick 2/5/10 marks, get board-style model answers (offline fuzzy-match bank + live AI) | ✅ / 🔑 |
| 10 | 🔤 **Vocabulary builder** — 110 words with Telugu meanings, flashcards, meaning quiz, learned-progress | ✅ |
| 11 | 📄 **Official textbook PDFs** — opens Govt. of Telangana TOSS textbooks & model papers/blue prints in-app links | ✅ |
| 12 | 🔑 **Bring-your-own Gemini key** — free key, stored only on the device | ✅ |

## 📖 Subjects & Official Sources

| Subject (both years) | Official free source (Govt. of Telangana) |
|---|---|
| Economics I & II | [TOSS Economics EM PDF](https://www.telanganaopenschool.org/images/Inter_pdfs/318_Inter_Economics_EM.pdf) |
| Commerce I & II | [TOSS Commerce/Business Studies EM PDF](https://www.telanganaopenschool.org/images/Inter_pdfs/319_Commerce_Business_Studies_EM.pdf) |
| Civics I & II | [TOSS Political Science EM PDF](https://www.telanganaopenschool.org/images/Inter_pdfs/317_INTER_POLITICAL_SCIENCE_EM.pdf) |
| Accountancy I & II | [TOSS Accountancy PDF](https://www.telanganaopenschool.org/images/Inter_pdfs/Accountancy%20Book.pdf) |
| English I & II | [Blue Print](https://www.telanganaopenschool.org/images/ssc_pdfs/Inter_English_Language_Blue_Print_2023.pdf) • [Model Paper](https://www.telanganaopenschool.org/images/ssc_pdfs/INTER_ENGLISH_Model_paper_2023.pdf) |
| Telugu I & II | [Blue Print](https://www.telanganaopenschool.org/images/ssc_pdfs/Inter_Telugu_Language_Blue_Print_2023.pdf) • [Model Paper](https://www.telanganaopenschool.org/images/ssc_pdfs/Telugu_Intermediate_model_paper_2023.pdf) |

> Full lists: [TOSS Inter Textbooks](https://www.telanganaopenschool.org/Intertextbooks.aspx) · [Model Papers & Blue Prints](https://www.telanganaopenschool.org/Inter_Model_QP_Blueprint.aspx) · [TSBIE](https://bie.tg.nic.in/)
> PDFs are **linked** from official government sites — the app never re-hosts copyrighted material.

---

## 🛠️ Build the Android app (APK)

You need [Flutter](https://docs.flutter.dev/get-started/install) installed (3.22+ recommended).

```bash
# 1. Clone the repo
git clone https://github.com/<your-username>/inter-ai-study-buddy.git
cd inter-ai-study-buddy

# 2. Generate the Android platform scaffolding (one-time)
flutter create --platforms=android .

# 3. Add permissions: open android/app/src/main/AndroidManifest.xml and add
#    ABOVE the <application> tag:
#      <uses-permission android:name="android.permission.INTERNET"/>
#      <uses-permission android:name="android.permission.RECORD_AUDIO"/>
#    (INTERNET = AI tutor + PDF links; RECORD_AUDIO = speak-to-tutor mic)

# 4. Fetch packages and run on a connected phone (USB debugging on)
flutter pub get
flutter run

# 5. Or build release APKs (found in build/app/outputs/flutter-apk/)
flutter build apk --release --split-per-abi
```

## 🔑 Free AI key (2 minutes)

1. Open [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) → sign in with any Google account → **Get API key** (free tier, generous limits).
2. In the app: **Settings → paste key → Save Key**.
3. The key is stored with `SharedPreferences` **only on the device** — it is never sent anywhere except to Google's Gemini API when you use AI features.

Without a key, everything except the live AI tutor / AI question generation works fully offline (the Exam Answer Writer falls back to the built-in question bank).

## 🗂️ Project structure

```
lib/
├── main.dart                  # app entry, providers
├── theme.dart                 # Material 3 theme
├── models.dart                # Subject, Chapter, QA, MCQ, VocabWord
├── data/
│   ├── year1_subjects.dart    # Inter 1st yr: 6 subjects, chapters, Q&A, MCQs
│   ├── year2_subjects.dart    # Inter 2nd yr: 6 subjects, chapters, Q&A, MCQs
│   └── vocabulary.dart        # 110 words + Telugu meanings
├── services/
│   ├── app_state.dart         # persisted state (key, scores, learned words)
│   ├── gemini_service.dart    # Gemini REST client with model fallbacks
│   └── speech_service.dart    # mic (speech_to_text) + voice (flutter_tts)
└── screens/
    ├── home_screen.dart       # dashboard + year toggle
    ├── subjects_screen.dart   # 6 subjects
    ├── chapter_screen.dart    # Learn | Questions | Textbook tabs
    ├── quiz_home_screen.dart  # pick subject
    ├── quiz_screen.dart       # MCQ player + AI question generator
    ├── tutor_screen.dart      # AI chat: Doubt Solver / ELI5, mic + TTS
    ├── exam_answer_screen.dart# 2/5/10-mark model answers
    ├── vocab_screen.dart      # flashcards + meaning quiz + AI words
    └── settings_screen.dart   # key, voice, official links, reset
```

## 🚧 Roadmap

- [ ] More chapters + previous-year question papers per subject
- [ ] Telugu Medium content toggle
- [ ] Spaced-repetition flashcard scheduler
- [ ] Daily streaks & study reminders
- [ ] iOS build (`flutter create --platforms=ios .`)

## ⚖️ License & fair use

MIT License (code). Study content is compiled for educational purposes aligned to the
TSBIE/TOSS syllabus; textbooks remain property of Govt. of Telangana and are linked, not re-hosted.
This is an independent student project — not affiliated with TSBIE/TOSS/SCERT.
