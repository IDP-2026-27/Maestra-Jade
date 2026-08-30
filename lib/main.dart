import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/curriculum_models.dart';
import 'models/masterclass_model.dart';
import 'services/lesson_service.dart';
import 'services/mentor_service.dart';
import 'services/student_performance_service.dart';
import 'services/voice_service.dart';
import 'widgets/teacher_avatar.dart';

void main() {
  runApp(const MaestraJadeLogicApp());
}

/// Root Application Widget with Google Fonts Nunito and a tablet-grade gamified theme.
class MaestraJadeLogicApp extends StatelessWidget {
  const MaestraJadeLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Maestra Jade: Logic & Pattern Masterclass",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10AC84), // Emerald Jade
          primary: const Color(0xFF10AC84),
          secondary: const Color(0xFF6C5CE7), // Royal Purple
          tertiary: const Color(0xFFFD9644), // Solar Amber
          surface: const Color(0xFFFAFBFD),
        ),
        scaffoldBackgroundColor: const Color(0xFFEDEAF8),
      ),
      home: const MasterclassLearningScreen(),
    );
  }
}

class MasterclassLearningScreen extends StatefulWidget {
  const MasterclassLearningScreen({super.key});

  @override
  State<MasterclassLearningScreen> createState() => _MasterclassLearningScreenState();
}

class _MasterclassLearningScreenState extends State<MasterclassLearningScreen> {
  // Services
  final LessonService _lessonService = LessonService();
  final VoiceService _voiceService = VoiceService();
  final MentorService _mentorService = MentorService();
  final StudentPerformanceService _performanceService = StudentPerformanceService();

  // App Modes: Part 1 (5-Min Masterclass) vs Part 2 (Practice Arena)
  AppMode _currentMode = AppMode.lessonMasterclass;
  AvatarAnimationState _avatarState = AvatarAnimationState.idle;
  AvatarEmotion _avatarEmotion = AvatarEmotion.encouraging;

  // Session State
  bool _hasStartedClassroom = false;
  final bool _isAutoAdvancing = true;

  // Quiz State
  String? _selectedQuizOption;
  bool? _lastAnswerCorrect;
  int _currentHintLevel = 1;
  late DateTime _questionStartTime;
  String _activeMentorDialogue = "";

  // Auto-advance Timer between chapters
  Timer? _autoAdvanceTimer;
  int _autoAdvanceCountdown = 0;

  @override
  void initState() {
    super.initState();
    _questionStartTime = DateTime.now();
    _activeMentorDialogue = _lessonService.currentChapter.teachingExplanation;

    _voiceService.isSpeaking.addListener(() {
      if (mounted) {
        setState(() {
          if (!_voiceService.isSpeaking.value &&
              _avatarState != AvatarAnimationState.celebrate &&
              _avatarState != AvatarAnimationState.thinking) {
            _avatarState = AvatarAnimationState.idle;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _voiceService.dispose();
    super.dispose();
  }

  // ==========================================
  // AUTONOMOUS MASTERCLASS SPEECH PIPELINE
  // ==========================================

  void _startClassroomSession() {
    setState(() {
      _hasStartedClassroom = true;
    });
    _playChapterAutonomously(_lessonService.currentChapterIndex);
  }

  void _playChapterAutonomously(int index) {
    _autoAdvanceTimer?.cancel();
    _lessonService.setChapter(index);
    final chapter = _lessonService.currentChapter;

    setState(() {
      _avatarState = AvatarAnimationState.explaining;
      _avatarEmotion = AvatarEmotion.encouraging;
      _activeMentorDialogue = chapter.teachingExplanation;
      _autoAdvanceCountdown = 0;
    });

    // Autonomous British Speech with completion callback
    _voiceService.speak(chapter.spokenNarration, onComplete: () {
      if (!mounted) return;
      setState(() => _avatarState = AvatarAnimationState.idle);

      if (!_isAutoAdvancing) return;

      if (index >= _lessonService.totalChapters - 1) {
        Timer(const Duration(seconds: 2), () {
          if (mounted) _enterQuizArenaAutonomously();
        });
      } else {
        setState(() => _autoAdvanceCountdown = 3);
        _autoAdvanceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          if (_autoAdvanceCountdown > 1) {
            setState(() => _autoAdvanceCountdown--);
          } else {
            timer.cancel();
            setState(() => _autoAdvanceCountdown = 0);
            _playChapterAutonomously(index + 1);
          }
        });
      }
    });
  }

  void _manualSelectChapter(int index) {
    _autoAdvanceTimer?.cancel();
    setState(() => _autoAdvanceCountdown = 0);
    _playChapterAutonomously(index);
  }

  void _manualNextChapter() {
    if (_lessonService.currentChapterIndex < _lessonService.totalChapters - 1) {
      _manualSelectChapter(_lessonService.currentChapterIndex + 1);
    } else {
      _enterQuizArenaAutonomously();
    }
  }

  void _manualPreviousChapter() {
    if (_lessonService.currentChapterIndex > 0) {
      _manualSelectChapter(_lessonService.currentChapterIndex - 1);
    }
  }

  // ==========================================
  // AUTONOMOUS QUIZ ARENA & LLM MENTOR PIPELINE
  // ==========================================

  void _enterQuizArenaAutonomously() {
    _autoAdvanceTimer?.cancel();
    final question = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);

    setState(() {
      _currentMode = AppMode.quizArena;
      _selectedQuizOption = null;
      _lastAnswerCorrect = null;
      _currentHintLevel = 1;
      _questionStartTime = DateTime.now();
      _avatarState = AvatarAnimationState.talking;
      _activeMentorDialogue = question.question;
    });

    _voiceService.speak("Challenge Arena Unlocked! ${question.spokenPrompt}");
  }

  Future<void> _handleQuizAnswer(String option) async {
    final question = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);
    final responseTimeMs = DateTime.now().difference(_questionStartTime).inMilliseconds;

    final isCorrect = option.trim().toLowerCase() == question.correctAnswer.toLowerCase() ||
        option.contains(question.correctAnswer);

    // Record learning signal in student session
    _performanceService.recordAnswer(
      question: question,
      selectedOption: option,
      responseTimeMs: responseTimeMs,
      hintsUsed: _currentHintLevel - 1,
    );

    // Invoke LLM Mentor for contextual evaluation
    final mentorResponse = await _mentorService.evaluateOrHint(
      sessionState: _performanceService.sessionState,
      currentQuestion: question,
      interactionType: isCorrect ? 'correct_answer' : 'incorrect_answer',
      studentAnswer: option,
    );

    setState(() {
      _selectedQuizOption = option;
      _lastAnswerCorrect = isCorrect;
      _avatarState = mentorResponse.avatarState;
      _avatarEmotion = mentorResponse.emotion;
      _activeMentorDialogue = mentorResponse.message;
    });

    // Speak verbal British feedback
    _voiceService.speak(mentorResponse.spokenText);
  }

  Future<void> _requestMentorClue() async {
    final question = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);
    _performanceService.recordHintRequest(question.id);

    final mentorResponse = await _mentorService.evaluateOrHint(
      sessionState: _performanceService.sessionState,
      currentQuestion: question,
      interactionType: 'hint',
      hintLevel: _currentHintLevel,
    );

    setState(() {
      _avatarState = mentorResponse.avatarState;
      _avatarEmotion = mentorResponse.emotion;
      _activeMentorDialogue = mentorResponse.message;
      if (_currentHintLevel < 3) {
        _currentHintLevel++;
      }
    });

    _voiceService.speak(mentorResponse.spokenText);
  }

  Future<void> _handleSkipQuestion() async {
    final question = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);
    _performanceService.recordSkip(question);

    final mentorResponse = await _mentorService.evaluateOrHint(
      sessionState: _performanceService.sessionState,
      currentQuestion: question,
      interactionType: 'skip',
    );

    _lessonService.nextQuizQuestion(_performanceService.currentDifficulty);
    final nextQ = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);

    setState(() {
      _selectedQuizOption = null;
      _lastAnswerCorrect = null;
      _currentHintLevel = 1;
      _questionStartTime = DateTime.now();
      _avatarState = mentorResponse.avatarState;
      _avatarEmotion = mentorResponse.emotion;
      _activeMentorDialogue = mentorResponse.message;
    });

    _voiceService.speak("${mentorResponse.spokenText} ${nextQ.spokenPrompt}");
  }

  void _nextQuizQuestion() {
    _lessonService.nextQuizQuestion(_performanceService.currentDifficulty);
    final q = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);

    setState(() {
      _selectedQuizOption = null;
      _lastAnswerCorrect = null;
      _currentHintLevel = 1;
      _questionStartTime = DateTime.now();
      _avatarState = AvatarAnimationState.talking;
      _activeMentorDialogue = q.question;
    });

    _voiceService.speak(q.spokenPrompt);
  }

  void _returnToMasterclass() {
    _autoAdvanceTimer?.cancel();
    setState(() {
      _currentMode = AppMode.lessonMasterclass;
    });
    _playChapterAutonomously(_lessonService.currentChapterIndex);
  }

  void _showApiKeyModal() {
    final controller = TextEditingController(text: _mentorService.effectiveApiKey);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.smart_toy_rounded, color: Color(0xFF10AC84)),
            SizedBox(width: 8),
            Text("LLM Mentor Settings", style: TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maestra Jade runs a genuine Gemini LLM Mentor. Enter your Gemini API Key below, or leave blank to use the built-in Socratic reasoning engine:",
              style: TextStyle(fontSize: 13, color: Color(0xFF636E72), height: 1.3),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "AIzaSy...",
                labelText: "Gemini API Key",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                prefixIcon: const Icon(Icons.key_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10AC84),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              _mentorService.setApiKey(controller.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("LLM Mentor configuration updated! ✨")),
              );
            },
            child: const Text("Save & Connect", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEDEAF8), Color(0xFFF4F2FC), Color(0xFFE8E4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Layout
              Column(
                children: [
                  // 1. TOP NAVIGATION
                  _buildTopNavBar(),

                  // 2. TEACHING MASTERCLASS BANNER
                  _buildMasterclassBanner(),

                  // 3. MAIN LESSON / QUIZ WORKSPACE
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: _currentMode == AppMode.lessonMasterclass
                          ? _buildLessonWorkspace()
                          : _buildQuizArenaWorkspace(),
                    ),
                  ),
                ],
              ),

              // First-time Classroom Start Overlay (Unlocks browser audio)
              if (!_hasStartedClassroom)
                _buildClassroomStartOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. TOP NAVIGATION
  // =========================================================================
  Widget _buildTopNavBar() {
    final diff = _performanceService.currentDifficulty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Left: Part 1 & Part 2 Mode Switcher
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D1457).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildModeTabButton(
                    title: "📖 Part 1: 5-Min Lesson",
                    isActive: _currentMode == AppMode.lessonMasterclass,
                    onTap: _returnToMasterclass,
                  ),
                  const SizedBox(width: 4),
                  _buildModeTabButton(
                    title: "❓ Part 2: Quiz Arena",
                    isActive: _currentMode == AppMode.quizArena,
                    onTap: _enterQuizArenaAutonomously,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Adaptive Difficulty Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFF6C5CE7)),
                  const SizedBox(width: 4),
                  Text(
                    diff.label.toUpperCase(),
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF6C5CE7)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right: Points Badge
            _buildPillBadge(
              icon: Icons.star_rounded,
              color: const Color(0xFFF1C40F),
              text: "${_performanceService.score} pts",
            ),
            const SizedBox(width: 8),

            // LLM Settings Trigger
            IconButton(
              onPressed: _showApiKeyModal,
              icon: const Icon(Icons.smart_toy_rounded, size: 20, color: Color(0xFF10AC84)),
              tooltip: "LLM Mentor API Settings",
            ),
            const SizedBox(width: 4),

            // Right: Audio / Mute Button
            ValueListenableBuilder<bool>(
              valueListenable: _voiceService.isMuted,
              builder: (context, isMuted, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      _voiceService.toggleMute();
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      child: Row(
                        children: [
                          Icon(
                            isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                            color: isMuted ? Colors.grey : const Color(0xFF10AC84),
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isMuted ? "Muted" : "Speaking 🇬🇧",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: isMuted ? Colors.grey : const Color(0xFF10AC84),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF10AC84) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: isActive ? Colors.white : const Color(0xFF2D3436),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 2. TEACHING MASTERCLASS BANNER
  // =========================================================================
  Widget _buildMasterclassBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF10AC84).withValues(alpha: 0.45), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10AC84).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Icon
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: Color(0xFF10AC84),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),

          // Banner Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      "🎓 TEACHING MASTERCLASS",
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10AC84),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10AC84).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 11, color: Color(0xFF10AC84)),
                          SizedBox(width: 3),
                          Text(
                            "AI MENTOR ACTIVE",
                            style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF10AC84)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _activeMentorDialogue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. MAIN LESSON WORKSPACE (Two-Column Responsive Layout)
  // =========================================================================
  Widget _buildLessonWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 640;

        if (isLandscape) {
          // Desktop / Tablet Two-Column Layout (40% Left Avatar, 60% Right Content Card)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left: Teacher Avatar (40%)
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D1457).withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TeacherAvatar(
                    state: _voiceService.isSpeaking.value ? AvatarAnimationState.explaining : _avatarState,
                    emotion: _avatarEmotion,
                    isSpeaking: _voiceService.isSpeaking.value,
                    teacherName: "Maestra Jade",
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Right: Dark Navy/Purple Lesson Content Card & Navigation (60%)
              Expanded(
                flex: 6,
                child: _buildLessonContentColumn(),
              ),
            ],
          );
        } else {
          // Mobile / Portrait Layout (Stacked Vertically)
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D1457).withValues(alpha: 0.08),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: TeacherAvatar(
                    state: _voiceService.isSpeaking.value ? AvatarAnimationState.explaining : _avatarState,
                    emotion: _avatarEmotion,
                    isSpeaking: _voiceService.isSpeaking.value,
                    teacherName: "Maestra Jade",
                  ),
                ),
                const SizedBox(height: 12),
                _buildLessonContentColumn(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildLessonContentColumn() {
    return Column(
      children: [
        Expanded(
          child: _buildDarkLessonContentCard(),
        ),
        const SizedBox(height: 10),
        _buildLessonNavigationControls(),
      ],
    );
  }

  Widget _buildDarkLessonContentCard() {
    final chapter = _lessonService.currentChapter;
    final currentCh = _lessonService.currentChapterIndex;
    final totalCh = _lessonService.totalChapters;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B162E), // Dark Navy/Purple
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF332D4F), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Dynamic Green Pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10AC84),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "CH ${chapter.chapterNumber}/$totalCh: ${chapter.durationLabel}",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (_autoAdvanceCountdown > 0)
                Text(
                  "Next in ${_autoAdvanceCountdown}s ⏳",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFD9644),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress / Action Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10AC84).withValues(alpha: 0.3)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildActionStepTag("1. Spot Core", isHighlighted: true),
                  const SizedBox(width: 8),
                  _buildActionStepTag("2. Chant Rhythm", isHighlighted: currentCh >= 1),
                  const SizedBox(width: 8),
                  _buildActionStepTag("3. Test Leap", isHighlighted: currentCh >= 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Step List with Sparkles
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: chapter.bulletPoints.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "✨ ",
                        style: TextStyle(fontSize: 13),
                      ),
                      Expanded(
                        child: Text(
                          chapter.bulletPoints[index],
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE2E8F0),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Bottom Chapter Navigation (Ch 1, Ch 2, Ch 3, Ch 4, Ch 5)
          _buildChapterNavigationRow(),
        ],
      ),
    );
  }

  Widget _buildActionStepTag(String text, {required bool isHighlighted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF10AC84).withValues(alpha: 0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted ? Border.all(color: const Color(0xFF00CEC9), width: 1.2) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: isHighlighted ? const Color(0xFF00CEC9) : const Color(0xFF636E72),
        ),
      ),
    );
  }

  Widget _buildChapterNavigationRow() {
    final currentCh = _lessonService.currentChapterIndex;
    final totalCh = _lessonService.totalChapters;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCh, (i) {
        final isCurrent = i == currentCh;
        final isDone = i < currentCh;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _manualSelectChapter(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.symmetric(horizontal: isCurrent ? 14 : 9, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFF10AC84)
                  : isDone
                      ? const Color(0xFF00CEC9).withValues(alpha: 0.3)
                      : const Color(0xFF2D2545),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Ch ${i + 1}",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isCurrent ? Colors.white : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        );
      }),
    );
  }

  // =========================================================================
  // 4. PREVIOUS / NEXT CONTROLS
  // =========================================================================
  Widget _buildLessonNavigationControls() {
    final currentCh = _lessonService.currentChapterIndex;
    final totalCh = _lessonService.totalChapters;
    final isLastChapter = currentCh == totalCh - 1;

    return Row(
      children: [
        if (currentCh > 0) ...[
          OutlinedButton.icon(
            onPressed: _manualPreviousChapter,
            icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF10AC84)),
            label: const Text("← Prev", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              side: const BorderSide(color: Color(0xFF10AC84), width: 1.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],

        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _manualNextChapter,
              icon: Icon(
                isLastChapter ? Icons.bolt_rounded : Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 22,
              ),
              label: Text(
                isLastChapter
                    ? "Enter Quiz Arena! 🎯"
                    : "Next Step (${currentCh + 2}/$totalCh) 🚀",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10AC84),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                elevation: 4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // QUIZ ARENA WORKSPACE WITH GENUINE LLM MENTOR
  // =========================================================================
  Widget _buildQuizArenaWorkspace() {
    final question = _lessonService.getCurrentQuestion(_performanceService.currentDifficulty);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 640;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isLandscape) ...[
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D1457).withValues(alpha: 0.08),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: TeacherAvatar(
                    state: _avatarState,
                    emotion: _avatarEmotion,
                    isSpeaking: _voiceService.isSpeaking.value,
                    teacherName: "Maestra Jade",
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],

            Expanded(
              flex: isLandscape ? 6 : 10,
              child: Column(
                children: [
                  // Dark Quiz Question Card
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B162E),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF332D4F), width: 1.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 22,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0984E3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "QUESTION ${_lessonService.currentQuizIndex + 1}/${_lessonService.totalQuizQuestions}",
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question.type.displayName,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00CEC9)),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "Tier: ${question.difficulty.name.toUpperCase()}",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFD9644)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Sequence Ribbon Box
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF0984E3).withValues(alpha: 0.5)),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: question.sequenceItems.map((item) {
                                  final isTarget = item.contains('❓') || item.contains('?');
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isTarget ? const Color(0xFFFD9644) : Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: isTarget ? Border.all(color: Colors.white, width: 1.5) : null,
                                    ),
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isTarget ? Colors.white : const Color(0xFF00CEC9),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            question.question,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Multiple Choice Grid
                  Expanded(
                    flex: 5,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.3,
                      physics: const NeverScrollableScrollPhysics(),
                      children: question.options.map((option) {
                        final isSelected = _selectedQuizOption == option;
                        final isCorrectOption = option == question.correctAnswer;

                        List<Color> cardColors;
                        if (isSelected) {
                          cardColors = (_lastAnswerCorrect == true)
                              ? [const Color(0xFF10AC84), const Color(0xFF2ED573)]
                              : [const Color(0xFFFF7675), const Color(0xFFE17055)];
                        } else if (_lastAnswerCorrect != null && isCorrectOption) {
                          cardColors = [const Color(0xFF10AC84), const Color(0xFF2ED573)];
                        } else {
                          cardColors = [const Color(0xFF6C5CE7), const Color(0xFF8C7AE6)];
                        }

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _handleQuizAnswer(option),
                            child: Ink(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: cardColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Actions: Clue & Skip & Next
                  Row(
                    children: [
                      if (_lastAnswerCorrect == true) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nextQuizQuestion,
                            icon: const Icon(Icons.navigate_next_rounded, color: Colors.white),
                            label: const Text(
                              "Next Challenge! ➡️",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10AC84),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _requestMentorClue,
                            icon: const Icon(Icons.lightbulb_rounded, size: 16, color: Color(0xFFFD9644)),
                            label: Text(
                              "Ask for a Clue (Tier $_currentHintLevel) 💡",
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFFD9644), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleSkipQuestion,
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                            label: const Text(
                              "Skip Question",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPillBadge({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.95)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomStartOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF1E1438).withValues(alpha: 0.92),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10AC84).withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10AC84).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/green_girl.png', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Maestra Jade's Masterclass",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3436),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Listen as Maestra Jade explains visual logic and pattern deduction autonomously in her British accent, supported by a genuine AI Mentor and adaptive practice challenges!",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF636E72),
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _startClassroomSession,
                    icon: const Icon(Icons.play_arrow_rounded, size: 30, color: Colors.white),
                    label: const Text(
                      "Start Masterclass 🎬 🇬🇧",
                      style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10AC84),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      elevation: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
