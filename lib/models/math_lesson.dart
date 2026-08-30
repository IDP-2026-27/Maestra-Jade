/// Educational flow phases for the interactive learning loop.
enum FlowPhase {
  lesson, // Phase 1: Concept explanation and narration
  quiz,   // Phase 2: Knowledge check and multiple-choice evaluation
}

/// Domain model for a kids' basic math lesson module.
class MathLesson {
  final String id;
  final String category; // e.g. "Counting", "Shapes", "Addition"
  final String visualConcept; // e.g. "🍎 + 🍎 = 🍏🍏"
  final String lessonExplanation; // Displayed concept text
  final String lessonSpeech; // Spoken text for Phase 1
  final String quizQuestion; // Displayed question for Phase 2
  final String quizSpeech; // Spoken text for Phase 2
  final List<String> options; // 4 multiple choice options
  final int correctOptionIndex;
  final String hint;
  final String celebratorySpeech; // Spoken on correct answer
  final String tryAgainSpeech; // Spoken on incorrect answer

  const MathLesson({
    required this.id,
    required this.category,
    required this.visualConcept,
    required this.lessonExplanation,
    required this.lessonSpeech,
    required this.quizQuestion,
    required this.quizSpeech,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
    required this.celebratorySpeech,
    required this.tryAgainSpeech,
  });

  String get correctAnswer => options[correctOptionIndex];
}

/// Structured outcome of evaluating a learner's quiz answer.
class EvaluationResult {
  final bool isCorrect;
  final String feedbackText;
  final String feedbackSpeech;
  final String? hint;
  final int starsAwarded;

  const EvaluationResult({
    required this.isCorrect,
    required this.feedbackText,
    required this.feedbackSpeech,
    this.hint,
    required this.starsAwarded,
  });
}
