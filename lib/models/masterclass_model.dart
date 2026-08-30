/// Modes representing the two distinct educational stages.
enum AppMode {
  lessonMasterclass, // Part 1: ~5-minute comprehensive interactive teaching
  quizArena,          // Part 2: Active practice quiz testing the taught rules
}

/// Domain model for a single interactive chapter in the 5-minute Masterclass.
class MasterclassChapter {
  final int chapterNumber;
  final String title;
  final String durationLabel; // e.g. "0:00 - 1:00"
  final String visualChalkboard; // e.g. "🔺 ➔ 🟦 ➔ 🔺 ➔ 🟦 ➔ 🔺 ➔ [ ? ]"
  final String conceptHeadline;
  final String teachingExplanation;
  final String spokenNarration; // Spoken by Maestra Jade's TTS
  final List<String> bulletPoints;

  const MasterclassChapter({
    required this.chapterNumber,
    required this.title,
    required this.durationLabel,
    required this.visualChalkboard,
    required this.conceptHeadline,
    required this.teachingExplanation,
    required this.spokenNarration,
    required this.bulletPoints,
  });
}

/// Domain model for a quiz arena challenge.
class QuizQuestion {
  final String id;
  final String category;
  final List<String> sequenceItems;
  final String questionText;
  final String spokenPrompt;
  final List<String> options;
  final int correctIndex;
  final String hint;
  final String celebrationSpeech;
  final String retrySpeech;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.sequenceItems,
    required this.questionText,
    required this.spokenPrompt,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.celebrationSpeech,
    required this.retrySpeech,
  });

  String get correctOption => options[correctIndex];
}

/// Quiz evaluation outcome.
class QuizEvaluation {
  final bool isCorrect;
  final String feedbackText;
  final String spokenFeedback;
  final String? hint;
  final int pointsEarned;

  const QuizEvaluation({
    required this.isCorrect,
    required this.feedbackText,
    required this.spokenFeedback,
    this.hint,
    required this.pointsEarned,
  });
}
