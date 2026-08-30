/// Represents a single question within the Spanish vocabulary curriculum.
class LessonQuestion {
  final String id;
  final String category; // e.g. "Body Parts" or "Classroom Objects"
  final String questionText; // e.g. "Which of these is 'la cabeza'?"
  final String targetSpanish; // e.g. "la cabeza"
  final String englishMeaning; // e.g. "the head"
  final List<String> options; // e.g. ["Head 🧠", "Hand ✋", "Eye 👁️", "Foot 🦶"]
  final int correctOptionIndex;
  final String hint; // e.g. "Think about what you nod with when saying yes! 🤔"
  final String celebratoryMessage; // e.g. "¡Excelente! 'La cabeza' is the head! 🎉"
  final String funFact; // e.g. "Did you know? In Spanish, 'cabeza' comes from Latin 'capitia'!"

  const LessonQuestion({
    required this.id,
    required this.category,
    required this.questionText,
    required this.targetSpanish,
    required this.englishMeaning,
    required this.options,
    required this.correctOptionIndex,
    required this.hint,
    required this.celebratoryMessage,
    required this.funFact,
  });

  String get correctAnswer => options[correctOptionIndex];
}

/// Evaluation result returned by the simulated LLM service.
class EvaluationResult {
  final bool isCorrect;
  final String feedbackMessage;
  final String? hint;
  final String teacherReaction;
  final int starsAwarded;

  const EvaluationResult({
    required this.isCorrect,
    required this.feedbackMessage,
    this.hint,
    required this.teacherReaction,
    required this.starsAwarded,
  });
}
