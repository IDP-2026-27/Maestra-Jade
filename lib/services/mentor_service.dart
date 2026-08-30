import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/curriculum_models.dart';

/// Genuine LLM Mentor Service powering Maestra Jade's pedagogical reasoning and reactions.
class MentorService {
  // Configured via --dart-define=LLM_API_KEY=... or dynamic server proxy
  static const String _envApiKey = String.fromEnvironment('LLM_API_KEY', defaultValue: '');
  String _customApiKey = '';

  void setApiKey(String key) {
    _customApiKey = key.trim();
  }

  String get effectiveApiKey => _customApiKey.isNotEmpty ? _customApiKey : _envApiKey;

  /// Main entry point for evaluating student actions, generating contextual hints, or adapting lessons.
  Future<MentorResponse> evaluateOrHint({
    required StudentSessionState sessionState,
    required ComprehensiveQuestion currentQuestion,
    required String interactionType, // 'hint', 'incorrect_answer', 'correct_answer', 'skip', 'lesson_intro'
    String? studentAnswer,
    int hintLevel = 1,
  }) async {
    final apiKey = effectiveApiKey;

    // If an API key is available, call the Gemini LLM API
    if (apiKey.isNotEmpty) {
      try {
        final llmResponse = await _callGeminiMentor(
          apiKey: apiKey,
          sessionState: sessionState,
          currentQuestion: currentQuestion,
          interactionType: interactionType,
          studentAnswer: studentAnswer,
          hintLevel: hintLevel,
        );
        if (llmResponse != null) {
          return llmResponse;
        }
      } catch (e) {
        debugPrint("[MentorService] LLM call fallback: $e");
      }
    }

    // Graceful, pedagogically rich fallback engine (100% reliable offline/fallback)
    return _generatePedagogicalFallback(
      sessionState: sessionState,
      currentQuestion: currentQuestion,
      interactionType: interactionType,
      studentAnswer: studentAnswer,
      hintLevel: hintLevel,
    );
  }

  /// Sends a structured contextual request to the LLM.
  Future<MentorResponse?> _callGeminiMentor({
    required String apiKey,
    required StudentSessionState sessionState,
    required ComprehensiveQuestion currentQuestion,
    required String interactionType,
    String? studentAnswer,
    required int hintLevel,
  }) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
    );

    final contextData = {
      'studentSession': sessionState.toContextJson(),
      'currentQuestion': {
        'id': currentQuestion.id,
        'type': currentQuestion.type.displayName,
        'difficulty': currentQuestion.difficulty.name,
        'sequence': currentQuestion.sequenceItems,
        'questionText': currentQuestion.question,
        'correctAnswer': currentQuestion.correctAnswer,
        'skillsTested': currentQuestion.skillsTested,
      },
      'interaction': {
        'type': interactionType,
        'studentAnswer': studentAnswer,
        'hintLevel': hintLevel,
      },
    };

    final prompt = """
You are Maestra Jade, a brilliant, warm, and highly engaging British mathematics & logic mentor for young students.
Your goal is to guide the student with Socratic encouragement and clear pattern-deduction rules.

Here is the student's live learning context:
${jsonEncode(contextData)}

RULES FOR YOUR RESPONSE:
1. Speak with a friendly British phrasing (e.g. "Spot on!", "Brilliant!", "Have a close look at...", "Let's chant the rhythm!").
2. For hints, DO NOT give away the answer directly unless hintLevel is 3. Instead, guide them by pointing out repeating units or arithmetic leaps.
3. Keep the spoken message concise (1-2 clear sentences) so text-to-speech stays engaging and quick.
4. Output STRICT JSON ONLY matching this format:
{
  "message": "...",
  "spokenText": "...",
  "intent": "hint|explain|encourage|celebrate|review",
  "avatarState": "talking|explaining|pointing|thinking|happy|excited|confused|celebrate",
  "emotion": "encouraging|happy|celebratory|supportive",
  "nextAction": "continue|retry|next_question",
  "difficultyAdjustment": 0
}
""";

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.6,
      }
    });

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?[0]?['parts']?[0]?['text'];
      if (text != null) {
        final Map<String, dynamic> parsed = jsonDecode(text);
        return MentorResponse.fromJson(parsed);
      }
    }
    return null;
  }

  /// High-precision pedagogical rule engine ensuring 100% reliable responses offline.
  MentorResponse _generatePedagogicalFallback({
    required StudentSessionState sessionState,
    required ComprehensiveQuestion currentQuestion,
    required String interactionType,
    String? studentAnswer,
    required int hintLevel,
  }) {
    if (interactionType == 'hint') {
      final hint = currentQuestion.getHintForLevel(hintLevel);
      return MentorResponse(
        message: "Clue (Level $hintLevel): ${hint.hintText}",
        spokenText: "Here's a clue: ${hint.spokenGuidance}",
        intent: 'hint',
        avatarState: hintLevel == 1 ? AvatarAnimationState.thinking : AvatarAnimationState.explaining,
        emotion: AvatarEmotion.encouraging,
        nextAction: 'retry',
      );
    } else if (interactionType == 'correct_answer') {
      final isStreakHigh = sessionState.currentStreak >= 3;
      return MentorResponse(
        message: isStreakHigh
            ? "¡Espléndido! That is ${sessionState.currentStreak} in a row! You mastered this pattern!"
            : "Spot on! ${currentQuestion.explanation}",
        spokenText: isStreakHigh
            ? "Splendid deduction! That's three in a row!"
            : "Spot on! ${currentQuestion.explanation}",
        intent: 'celebrate',
        avatarState: isStreakHigh ? AvatarAnimationState.celebrate : AvatarAnimationState.happy,
        emotion: AvatarEmotion.celebratory,
        nextAction: 'next_question',
        difficultyAdjustment: sessionState.currentStreak >= 3 ? 1 : 0,
      );
    } else if (interactionType == 'incorrect_answer') {
      final subtleClue = currentQuestion.getHintForLevel(1);
      return MentorResponse(
        message: "Nearly there! ${subtleClue.hintText}",
        spokenText: "Nearly there! Remember Jade's Golden Rule: ${subtleClue.spokenGuidance}",
        intent: 'encourage',
        avatarState: AvatarAnimationState.confused,
        emotion: AvatarEmotion.supportive,
        nextAction: 'retry',
        difficultyAdjustment: 0,
      );
    } else if (interactionType == 'skip') {
      return const MentorResponse(
        message: "No problem at all! Let's explore a fresh challenge together.",
        spokenText: "No worries! Let's move onto a fresh puzzle together.",
        intent: 'encourage',
        avatarState: AvatarAnimationState.explaining,
        emotion: AvatarEmotion.encouraging,
        nextAction: 'next_question',
      );
    } else {
      return MentorResponse(
        message: currentQuestion.question,
        spokenText: currentQuestion.spokenPrompt,
        intent: 'explain',
        avatarState: AvatarAnimationState.talking,
        emotion: AvatarEmotion.neutral,
        nextAction: 'continue',
      );
    }
  }
}
