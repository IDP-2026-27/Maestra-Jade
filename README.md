# 🎓 Maestra Jade: Logic & Pattern Masterclass

An autonomous, interactive educational platform featuring an animated teacher (**Maestra Jade**), synchronized British voice narration (`en-GB`), a multi-tiered pattern & logic reasoning curriculum, and a genuine **Gemini LLM Socratic Mentor**.

---

## 🌟 Key Features

- **📖 Part 1: 5-Minute Masterclass**: Autonomous chapter-by-chapter course teaching repeating cores, $+2$ growth leaps, and deduction rules on an interactive digital chalkboard.
- **❓ Part 2: Quiz Arena**: Practice arena featuring 8 diverse question categories across 4 difficulty tiers (*Easy*, *Medium*, *Hard*, *Challenge*).
- **🎭 State-Driven Animated Avatar**: Maestra Jade features an active state machine (`idle`, `talking`, `explaining`, `pointing`, `thinking`, `happy`, `excited`, `confused`, `celebrate`, `sad`) with organic micro-dynamics, pose transitions, and glowing mood auras.
- **🔊 Real-Time Voice Synchronization**: Event-driven Web Speech API & TTS engine (`en-GB`) where character gestures and speech indicators bind directly to speech playback lifecycle events.
- **🤖 Genuine Gemini LLM Socratic Mentor**: Context-aware AI mentor that analyzes student accuracy, response times, and mistakes to provide progressive multi-tiered clues without immediately giving away answers.
- **⚡ Adaptive Difficulty Engine**: Dynamically promotes or demotes challenge tiers based on streaks and error patterns.
- **📊 Observable Engagement Tracking**: Analyzes response latency and interaction patterns to tailor the pace of explanations responsibly.

---

## 🏗️ Architecture

```
                 GITHUB REPOSITORY
                         │
                         │ git push main
                         ▼
             CI / BUILD / TEST (GitHub Actions)
                         │
                         ▼
             PRODUCTION DEPLOYMENT (GitHub Pages / Vercel)
                         │
          ┌──────────────┴──────────────┐
          ▼                             ▼
   FRONTEND UI                     SERVICE LAYER
   ├── TopNavigation               ├── MentorService (Gemini LLM)
   ├── MasterclassBanner           ├── StudentPerformanceService
   ├── TeacherAvatar               ├── QuestionBank (Multi-Tier)
   ├── DarkLessonCard              ├── LessonService
   └── QuizArena                   └── VoiceService (en-GB TTS)
          │                             │
          └──────────────┬──────────────┘
                         ▼
             ANIMATED MAESTRA JADE
             ├── Natural Breathing & Gestures
             ├── Live Pose Switching
             └── Voice-Synchronized State Machine
```

---

## 🚀 Local Setup & Installation

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version `>= 3.13.2`)
- Google Chrome or Microsoft Edge

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/kids-quest.git
cd kids-quest
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run in Development Mode
```bash
# Launch on Google Chrome
flutter run -d chrome

# Or launch on Microsoft Edge
flutter run -d edge

# Optional: Run with Gemini API Key injected via command line
flutter run -d chrome --dart-define=LLM_API_KEY=YOUR_GEMINI_API_KEY
```

---

## 🧪 Testing & Code Quality

Run static analysis and automated widget tests before committing changes:

```bash
# Static analysis / linter check (ensure 0 issues)
flutter analyze

# Run automated widget test suite
flutter test
```

---

## 📦 Production Build

Build the optimized web bundle:

```bash
# Standard release build
flutter build web --release

# Release build with custom base href (e.g. for GitHub Pages sub-path)
flutter build web --release --base-href "/kids-quest/"
```
The compiled static assets will be located in the `build/web` directory.

---

## 🔐 Environment Variables & Security

| Variable | Description | Default |
|---|---|---|
| `LLM_API_KEY` | Google Gemini API Key for Maestra Jade's Socratic Mentor | *(Optional, falls back to local pedagogical engine)* |
| `TTS_LANGUAGE` | Default voice locale | `en-GB` |

> **Security Note**: Never commit actual API keys to GitHub. You can pass the API key during build time via `--dart-define=LLM_API_KEY=...` or enter it securely at runtime inside the in-app **LLM Settings (🤖)** modal.

---

## 🔄 Git & Deployment Workflow

We use a conventional Git workflow where `main` is the stable production branch:

```bash
# 1. Create a feature branch or make local modifications
git checkout -b feat/new-curriculum-chapter

# 2. Verify code quality and run tests
flutter analyze
flutter test

# 3. Commit with a meaningful conventional commit message
git commit -m "feat: add 2x2 matrix reasoning questions"

# 4. Push to GitHub
git push origin main
```

Upon pushing to `main`, the `.github/workflows/deploy.yml` workflow automatically runs the test suite, builds the web application, and deploys it live to **GitHub Pages**.

---

## 📄 License
This project is licensed under the MIT License.
