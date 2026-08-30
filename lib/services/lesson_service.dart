import '../models/curriculum_models.dart';
import '../models/masterclass_model.dart';
import 'question_bank.dart';

/// Service Layer orchestrating the 5-Minute Masterclass Lesson and Practice Quiz Arena.
class LessonService {
  // Masterclass Chapters (5-minute comprehensive instructional course)
  static const List<MasterclassChapter> masterclassChapters = [
    MasterclassChapter(
      chapterNumber: 1,
      title: "The Mystery of Patterns",
      durationLabel: "0:00 - 1:00",
      visualChalkboard: "🔺 ➔ 🟦 ➔ 🔺 ➔ 🟦 ➔ 🔺 ➔ [ ? ]",
      conceptHeadline: "What is a pattern? Look for the repeating rhythm!",
      teachingExplanation:
          "A pattern is a secret rhythm in shapes, colors, and numbers. When you see a puzzle, don't guess — look for the repeating beat!",
      spokenNarration:
          "Welcome to our 5-minute Pattern Masterclass! I'm Maestra Jade. A pattern is a secret rhythm in shapes and numbers. When you look at a puzzle, don't guess — look for the repeating beat!",
      bulletPoints: [
        "Patterns follow a hidden rhythm",
        "Shapes repeat in precise order",
        "Look for the beat before you answer!",
      ],
    ),
    MasterclassChapter(
      chapterNumber: 2,
      title: "Finding the Repeating Core",
      durationLabel: "1:00 - 2:00",
      visualChalkboard: "[ 🔺 🟦 ] ➔ [ 🔺 🟦 ] ➔ [ 🔺 ... ]",
      conceptHeadline: "Step 1: Group the shapes into repeating pairs!",
      teachingExplanation:
          "Group the shapes into pairs! Notice how every single Triangle is followed by a Blue Square? That means the core repeating unit is [Triangle + Square]!",
      spokenNarration:
          "Step one: Group the shapes into pairs! Notice how every single Triangle is followed by a Blue Square? That means the core repeating unit is Triangle plus Square!",
      bulletPoints: [
        "Group the sequence into repeating pairs",
        "Lead shape: Triangle 🔺",
        "Follower shape: Square 🟦",
      ],
    ),
    MasterclassChapter(
      chapterNumber: 3,
      title: "The Secret +2 Leap",
      durationLabel: "2:00 - 3:00",
      visualChalkboard: "2 (+2)➔ 4 (+2)➔ 6 (+2)➔ 8 (+2)➔ [ 10 ]",
      conceptHeadline: "Step 2: Patterns can grow by leaping forward!",
      teachingExplanation:
          "Patterns can also grow! Watch these numbers leap: 2 jumps to 4, 4 jumps to 6, 6 jumps to 8. Every leap adds plus two! What is 8 plus 2? It is 10!",
      spokenNarration:
          "Patterns can also grow! Watch these numbers leap: two jumps to four, four jumps to six, six jumps to eight. Every leap adds plus two! Eight plus two equals ten!",
      bulletPoints: [
        "Calculate the jump: +2 at each step",
        "Count by twos: 2, 4, 6, 8...",
        "8 + 2 = 10!",
      ],
    ),
    MasterclassChapter(
      chapterNumber: 4,
      title: "Jade's 3 Golden Rules",
      durationLabel: "3:00 - 4:00",
      visualChalkboard: "1. Spot Core 🔍   2. Chant Rhythm 🗣️   3. Test Leap ✅",
      conceptHeadline: "Step 3: Master the 3 Golden Rules of Deduction!",
      teachingExplanation:
          "Remember my 3 Golden Rules: One, spot the repeating core. Two, chant the rhythm out loud. Three, test your answer before locking it in!",
      spokenNarration:
          "Remember my three Golden Rules: One, spot the repeating core unit. Two, chant the rhythm out loud. Three, test your answer before locking it in!",
      bulletPoints: [
        "1. Spot the Core unit",
        "2. Chant the rhythm out loud",
        "3. Test your answer before locking in!",
      ],
    ),
    MasterclassChapter(
      chapterNumber: 5,
      title: "Masterclass Complete!",
      durationLabel: "4:00 - 5:00",
      visualChalkboard: "🎓 Masterclass Complete! Practice Arena Ready 🔓",
      conceptHeadline: "You're a Pattern Master! Practice Arena Unlocked!",
      teachingExplanation:
          "¡Fantástico! You have mastered the logic principles! You are now ready for the Practice Arena where you will solve pattern challenges on your own!",
      spokenNarration:
          "¡Fantástico! You have mastered the logic principles! You are now ready for the Practice Arena where you will solve pattern challenges on your own! Let's begin the quiz!",
      bulletPoints: [
        "5-minute Masterclass complete!",
        "Logic & deduction principles unlocked",
        "Tap 'Enter Quiz Arena' to test your skills!",
      ],
    ),
  ];

  int _currentChapterIndex = 0;
  int _currentQuizIndex = 0;
  final List<String> _recentQuestionIds = [];

  // Masterclass Getters
  int get currentChapterIndex => _currentChapterIndex;
  int get totalChapters => masterclassChapters.length;
  MasterclassChapter get currentChapter => masterclassChapters[_currentChapterIndex];

  void setChapter(int index) {
    if (index >= 0 && index < masterclassChapters.length) {
      _currentChapterIndex = index;
    }
  }

  void nextChapter() {
    if (_currentChapterIndex < masterclassChapters.length - 1) {
      _currentChapterIndex++;
    }
  }

  void previousChapter() {
    if (_currentChapterIndex > 0) {
      _currentChapterIndex--;
    }
  }

  // Quiz Arena Getters
  int get currentQuizIndex => _currentQuizIndex;
  int get totalQuizQuestions => QuestionBank.allQuestions.length;

  ComprehensiveQuestion getCurrentQuestion(DifficultyLevel difficulty) {
    if (_currentQuizIndex >= 0 && _currentQuizIndex < QuestionBank.allQuestions.length) {
      return QuestionBank.allQuestions[_currentQuizIndex];
    }
    return QuestionBank.allQuestions.first;
  }

  ComprehensiveQuestion getAdaptiveQuestion(DifficultyLevel difficulty) {
    final nextQ = QuestionBank.selectNextAdaptiveQuestion(
      currentDifficulty: difficulty,
      recentQuestionIds: _recentQuestionIds,
    );
    _recentQuestionIds.add(nextQ.id);
    if (_recentQuestionIds.length > 15) {
      _recentQuestionIds.removeAt(0);
    }
    _currentQuizIndex = QuestionBank.allQuestions.indexOf(nextQ);
    return nextQ;
  }

  void nextQuizQuestion(DifficultyLevel difficulty) {
    _currentQuizIndex = (_currentQuizIndex + 1) % QuestionBank.allQuestions.length;
  }

  void resetAll() {
    _currentChapterIndex = 0;
    _currentQuizIndex = 0;
    _recentQuestionIds.clear();
  }
}
