import '../models/curriculum_models.dart';

/// Service managing student session state, performance metrics, and adaptive difficulty.
class StudentPerformanceService {
  final StudentSessionState _sessionState = StudentSessionState();

  StudentSessionState get sessionState => _sessionState;
  DifficultyLevel get currentDifficulty => _sessionState.currentDifficulty;
  int get score => _score;
  int _score = 0;

  void recordAnswer({
    required ComprehensiveQuestion question,
    required String selectedOption,
    required int responseTimeMs,
    required int hintsUsed,
  }) {
    _sessionState.questionsAttempted++;
    final isCorrect = selectedOption.trim().toLowerCase() == question.correctAnswer.toLowerCase() ||
        selectedOption.contains(question.correctAnswer);

    if (isCorrect) {
      _sessionState.correctAnswers++;
      _sessionState.currentStreak++;
      final basePoints = question.difficulty.level * 20;
      final streakBonus = _sessionState.currentStreak * 10;
      _score += basePoints + streakBonus;

      // Update concept mastery
      final currentMastery = _sessionState.conceptMastery[question.conceptId] ?? 0.5;
      _sessionState.conceptMastery[question.conceptId] = (currentMastery + 0.15).clamp(0.0, 1.0);
    } else {
      _sessionState.incorrectAnswers++;
      _sessionState.currentStreak = 0;
      _sessionState.recordedMistakes.add(
        "Chose '$selectedOption' for ${question.type.displayName} (Expected: '${question.correctAnswer}')",
      );

      // Decrease concept mastery slightly
      final currentMastery = _sessionState.conceptMastery[question.conceptId] ?? 0.5;
      _sessionState.conceptMastery[question.conceptId] = (currentMastery - 0.1).clamp(0.0, 1.0);
    }

    _sessionState.recentAnswers.insert(
      0,
      RecentAnswerRecord(
        questionId: question.id,
        isCorrect: isCorrect,
        responseTimeMs: responseTimeMs,
        hintsUsed: hintsUsed,
        selectedOption: selectedOption,
      ),
    );

    // Keep history manageable
    if (_sessionState.recentAnswers.length > 20) {
      _sessionState.recentAnswers.removeLast();
    }

    _checkAndAdjustDifficulty();
  }

  void recordHintRequest(String questionId) {
    _sessionState.totalHintsRequested++;
  }

  void recordSkip(ComprehensiveQuestion question) {
    _sessionState.skippedQuestions++;
    _sessionState.recordedMistakes.add("Skipped question '${question.id}' (${question.type.displayName})");
  }

  void _checkAndAdjustDifficulty() {
    // Elevate difficulty if student is doing exceptionally well
    if (_sessionState.currentStreak >= 3 && _sessionState.accuracy >= 0.8) {
      if (_sessionState.currentDifficulty == DifficultyLevel.easy) {
        _sessionState.currentDifficulty = DifficultyLevel.medium;
      } else if (_sessionState.currentDifficulty == DifficultyLevel.medium) {
        _sessionState.currentDifficulty = DifficultyLevel.hard;
      } else if (_sessionState.currentDifficulty == DifficultyLevel.hard) {
        _sessionState.currentDifficulty = DifficultyLevel.challenge;
      }
    }

    // Ease difficulty if student has 3 consecutive errors
    final recent3 = _sessionState.recentAnswers.take(3).toList();
    if (recent3.length == 3 && recent3.every((a) => !a.isCorrect)) {
      if (_sessionState.currentDifficulty == DifficultyLevel.challenge) {
        _sessionState.currentDifficulty = DifficultyLevel.hard;
      } else if (_sessionState.currentDifficulty == DifficultyLevel.hard) {
        _sessionState.currentDifficulty = DifficultyLevel.medium;
      } else if (_sessionState.currentDifficulty == DifficultyLevel.medium) {
        _sessionState.currentDifficulty = DifficultyLevel.easy;
      }
    }
  }

  void setDifficulty(DifficultyLevel difficulty) {
    _sessionState.currentDifficulty = difficulty;
  }

  void resetSession() {
    _sessionState.questionsAttempted = 0;
    _sessionState.correctAnswers = 0;
    _sessionState.incorrectAnswers = 0;
    _sessionState.skippedQuestions = 0;
    _sessionState.totalHintsRequested = 0;
    _sessionState.recentAnswers.clear();
    _sessionState.recordedMistakes.clear();
    _sessionState.conceptMastery.clear();
    _sessionState.currentStreak = 0;
    _score = 0;
  }
}
