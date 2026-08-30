/// Educational flow phases for the logic and pattern sequence challenge.
enum FlowPhase {
  lesson, // Phase 1: Concept introduction & rule explanation
  quiz,   // Phase 2: Active challenge & sequence completion
}

/// Domain model for a pattern sequencing & visual logic unit.
class LogicLesson {
  final String id;
  final String title;
  final String category; // e.g. "Pattern Sequencing", "Growth Progression", "Cycle Logic"
  final List<String> sequenceDisplay; // e.g. ["🔺", "🟦", "🔺", "🟦", "🔺", "❓"]
  final String ruleExplanation; // Core logic rule displayed to student
  final String lessonNarration; // Spoken by TTS during Phase 1
  final String challengePrompt; // Question prompt during Phase 2
  final String challengeNarration; // Spoken by TTS during Phase 2
  final List<String> options; // 4 interactive answer choices
  final int correctIndex;
  final String hint;
  final String celebrationSpeech;
  final String retrySpeech;

  const LogicLesson({
    required this.id,
    required this.title,
    required this.category,
    required this.sequenceDisplay,
    required this.ruleExplanation,
    required this.lessonNarration,
    required this.challengePrompt,
    required this.challengeNarration,
    required this.options,
    required this.correctIndex,
    required this.hint,
    required this.celebrationSpeech,
    required this.retrySpeech,
  });

  String get correctOption => options[correctIndex];
}

/// Result of evaluating an answer choice in the logic challenge.
class EvaluationResult {
  final bool isCorrect;
  final String message;
  final String spokenFeedback;
  final String? hint;
  final int pointsEarned;

  const EvaluationResult({
    required this.isCorrect,
    required this.message,
    required this.spokenFeedback,
    this.hint,
    required this.pointsEarned,
  });
}
