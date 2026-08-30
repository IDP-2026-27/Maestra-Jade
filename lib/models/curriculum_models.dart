/// Scalable Curriculum and LLM Mentor Data Models for Logic & Pattern Learning Platform.
library;

/// Difficulty tiers supported across all questions and lessons.
enum DifficultyLevel {
  easy('Easy', 1),
  medium('Medium', 2),
  hard('Hard', 3),
  challenge('Challenge', 4);

  final String label;
  final int level;
  const DifficultyLevel(this.label, this.level);

  static DifficultyLevel fromString(String str) {
    return DifficultyLevel.values.firstWhere(
      (d) => d.name.toLowerCase() == str.toLowerCase(),
      orElse: () => DifficultyLevel.medium,
    );
  }
}

/// Rich classification of visual and logical reasoning problem types.
enum QuestionType {
  sequencePattern('Sequence Pattern'),
  shapePattern('Shape Pattern'),
  numberGrowth('Number Growth / Skip Counting'),
  logicalReasoning('Logical Reasoning'),
  oddOneOut('Odd One Out'),
  ordering('Ordering & Hierarchy'),
  classification('Category Classification'),
  visualDeduction('Visual Matrix Deduction');

  final String displayName;
  const QuestionType(this.displayName);
}

/// Avatar Animation & Expressive States
enum AvatarAnimationState {
  idle('Idle', 'Neutral resting breathing posture'),
  talking('Talking', 'Active speech mouth and body posture'),
  explaining('Explaining', 'Gesturing with pointer towards lesson concept'),
  pointing('Pointing', 'Pointing directly at chalkboard rule'),
  thinking('Thinking', 'Reflective posture awaiting student answer'),
  happy('Happy', 'Warm joyful smile'),
  excited('Excited', 'Energetic enthusiasm'),
  confused('Confused', 'Puzzled / encouraging head tilt'),
  celebrate('Celebrate', 'Victory peace sign and joyful celebration'),
  sad('Sad', 'Empathetic gentle encouragement');

  final String stateName;
  final String description;
  const AvatarAnimationState(this.stateName, this.description);

  static AvatarAnimationState fromString(String str) {
    return AvatarAnimationState.values.firstWhere(
      (a) => a.name.toLowerCase() == str.toLowerCase(),
      orElse: () => AvatarAnimationState.idle,
    );
  }
}

/// Emotional nuance accompanying avatar animation.
enum AvatarEmotion {
  neutral,
  encouraging,
  happy,
  curious,
  celebratory,
  supportive;

  static AvatarEmotion fromString(String str) {
    return AvatarEmotion.values.firstWhere(
      (e) => e.name.toLowerCase() == str.toLowerCase(),
      orElse: () => AvatarEmotion.encouraging,
    );
  }
}

/// Single interactive Concept in a Lesson.
class Concept {
  final String id;
  final String name;
  final String coreRule;
  final String visualRepresentation;

  const Concept({
    required this.id,
    required this.name,
    required this.coreRule,
    required this.visualRepresentation,
  });
}

/// Concrete worked example demonstrated by Maestra Jade.
class LessonExample {
  final String question;
  final String visualChalkboard;
  final String explanation;
  final String answer;

  const LessonExample({
    required this.question,
    required this.visualChalkboard,
    required this.explanation,
    required this.answer,
  });
}

/// Multi-tier progressive hint system.
class ProgressiveHint {
  final int level; // 1: Subtle clue, 2: Stronger hint, 3: Full breakdown
  final String hintText;
  final String spokenGuidance;

  const ProgressiveHint({
    required this.level,
    required this.hintText,
    required this.spokenGuidance,
  });
}

/// Comprehensive, scalable Question model.
class ComprehensiveQuestion {
  final String id;
  final String conceptId;
  final QuestionType type;
  final DifficultyLevel difficulty;
  final List<String> sequenceItems;
  final String question;
  final String spokenPrompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final List<ProgressiveHint> progressiveHints;
  final List<String> skillsTested;

  const ComprehensiveQuestion({
    required this.id,
    required this.conceptId,
    required this.type,
    required this.difficulty,
    required this.sequenceItems,
    required this.question,
    required this.spokenPrompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.progressiveHints,
    required this.skillsTested,
  });

  String get correctAnswer => options[correctIndex];

  ProgressiveHint getHintForLevel(int level) {
    if (progressiveHints.isEmpty) {
      return ProgressiveHint(
        level: level,
        hintText: "Observe what changes in each step of the pattern.",
        spokenGuidance: "Look closely at the pattern sequence!",
      );
    }
    return progressiveHints.firstWhere(
      (h) => h.level == level,
      orElse: () => progressiveHints.last,
    );
  }
}

/// A structured Lesson within a Chapter.
class LessonUnit {
  final String id;
  final String title;
  final int chapterNumber;
  final String durationLabel;
  final DifficultyLevel difficulty;
  final List<String> objectives;
  final List<String> teachingPoints;
  final List<LessonExample> examples;
  final String visualChalkboard;
  final String teachingExplanation;
  final String spokenNarration;
  final List<String> bulletPoints;

  const LessonUnit({
    required this.id,
    required this.title,
    required this.chapterNumber,
    required this.durationLabel,
    required this.difficulty,
    required this.objectives,
    required this.teachingPoints,
    required this.examples,
    required this.visualChalkboard,
    required this.teachingExplanation,
    required this.spokenNarration,
    required this.bulletPoints,
  });
}

/// Student's live session state for LLM context generation.
class StudentSessionState {
  int currentChapter;
  String currentLessonId;
  String currentConceptId;
  DifficultyLevel currentDifficulty;
  DateTime sessionStartTime;
  int questionsAttempted;
  int correctAnswers;
  int incorrectAnswers;
  int skippedQuestions;
  int totalHintsRequested;
  List<RecentAnswerRecord> recentAnswers;
  Map<String, double> conceptMastery;
  List<String> recordedMistakes;
  int currentStreak;

  StudentSessionState({
    this.currentChapter = 1,
    this.currentLessonId = 'lesson_1_patterns',
    this.currentConceptId = 'concept_ab_rhythm',
    this.currentDifficulty = DifficultyLevel.easy,
    DateTime? sessionStartTime,
    this.questionsAttempted = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.skippedQuestions = 0,
    this.totalHintsRequested = 0,
    List<RecentAnswerRecord>? recentAnswers,
    Map<String, double>? conceptMastery,
    List<String>? recordedMistakes,
    this.currentStreak = 0,
  })  : sessionStartTime = sessionStartTime ?? DateTime.now(),
        recentAnswers = recentAnswers ?? [],
        conceptMastery = conceptMastery ?? {},
        recordedMistakes = recordedMistakes ?? [];

  double get accuracy => questionsAttempted == 0 ? 1.0 : (correctAnswers / questionsAttempted);

  /// Computes observable engagement score responsibly (0.0 to 1.0)
  double get engagementScore {
    if (questionsAttempted == 0) return 1.0;
    double score = 0.5;
    if (recentAnswers.isNotEmpty) {
      final avgTimeMs = recentAnswers.map((a) => a.responseTimeMs).reduce((a, b) => a + b) / recentAnswers.length;
      if (avgTimeMs > 2000 && avgTimeMs < 45000) score += 0.3; // Thoughtful answering pace
    }
    if (accuracy > 0.4) score += 0.2;
    return score.clamp(0.1, 1.0);
  }

  Map<String, dynamic> toContextJson() {
    return {
      'studentSession': {
        'currentChapter': currentChapter,
        'currentLessonId': currentLessonId,
        'currentConceptId': currentConceptId,
        'currentDifficulty': currentDifficulty.name,
      },
      'performance': {
        'questionsAttempted': questionsAttempted,
        'correct': correctAnswers,
        'incorrect': incorrectAnswers,
        'skipped': skippedQuestions,
        'accuracy': '${(accuracy * 100).toStringAsFixed(1)}%',
        'currentStreak': currentStreak,
        'hintsRequested': totalHintsRequested,
        'engagementScore': '${(engagementScore * 100).toStringAsFixed(0)}%',
      },
      'recentAnswers': recentAnswers.take(5).map((a) => a.toJson()).toList(),
      'recordedMistakes': recordedMistakes.take(5).toList(),
      'conceptMastery': conceptMastery,
    };
  }
}

/// Record of a recent question interaction.
class RecentAnswerRecord {
  final String questionId;
  final bool isCorrect;
  final int responseTimeMs;
  final int hintsUsed;
  final String selectedOption;
  final String timestamp;

  RecentAnswerRecord({
    required this.questionId,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.hintsUsed,
    required this.selectedOption,
    String? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'isCorrect': isCorrect,
        'responseTimeMs': responseTimeMs,
        'hintsUsed': hintsUsed,
        'selectedOption': selectedOption,
      };
}

/// Structured response output by the LLM Mentor.
class MentorResponse {
  final String message;
  final String spokenText;
  final String intent; // explain, hint, encourage, celebrate, review, difficultyAdjustment
  final AvatarAnimationState avatarState;
  final AvatarEmotion emotion;
  final String nextAction; // continue, retry, next_question, show_clue
  final int difficultyAdjustment; // -1 (easier), 0 (maintain), +1 (harder)

  const MentorResponse({
    required this.message,
    required this.spokenText,
    required this.intent,
    required this.avatarState,
    required this.emotion,
    required this.nextAction,
    this.difficultyAdjustment = 0,
  });

  factory MentorResponse.fromJson(Map<String, dynamic> json) {
    return MentorResponse(
      message: json['message'] ?? "Let's explore this logic pattern together!",
      spokenText: json['spokenText'] ?? json['message'] ?? "Let's explore this logic pattern together!",
      intent: json['intent'] ?? 'explain',
      avatarState: AvatarAnimationState.fromString(json['avatarState'] ?? 'explaining'),
      emotion: AvatarEmotion.fromString(json['emotion'] ?? 'encouraging'),
      nextAction: json['nextAction'] ?? 'continue',
      difficultyAdjustment: json['difficultyAdjustment'] is int ? json['difficultyAdjustment'] : 0,
    );
  }
}
