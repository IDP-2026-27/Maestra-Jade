import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

// Conditional JavaScript interop for Web Speech Synthesis
import 'voice_interop_stub.dart' if (dart.library.js_interop) 'voice_interop_web.dart';

/// Autonomous British Voice Engine for Maestra Jade.
/// Speaks automatically throughout the masterclass & quiz with en-GB British accent.
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<bool> isSpeaking = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);

  VoidCallback? _onSpeechCompleteCallback;
  bool _isInitialized = false;

  VoiceService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage("en-GB");
      await _tts.setSpeechRate(0.48); // Natural articulate British pace
      await _tts.setPitch(1.18); // Cheerful, bright teacher tone
      await _tts.setVolume(1.0);

      // Attempt to bind UK/British voice
      try {
        final voices = await _tts.getVoices;
        if (voices != null && voices is List) {
          for (var v in voices) {
            if (v is Map) {
              final name = (v['name'] ?? '').toString().toLowerCase();
              final locale = (v['locale'] ?? '').toString().toLowerCase();
              if (locale.contains('en-gb') ||
                  locale.contains('en_gb') ||
                  name.contains('uk') ||
                  name.contains('british') ||
                  name.contains('hazel') ||
                  name.contains('george')) {
                await _tts.setVoice({"name": v['name'], "locale": v['locale']});
                break;
              }
            }
          }
        }
      } catch (_) {}

      if (kIsWeb) {
        await _tts.awaitSpeakCompletion(false);
      } else {
        await _tts.awaitSpeakCompletion(true);
      }

      _tts.setStartHandler(() {
        isSpeaking.value = true;
      });

      _tts.setCompletionHandler(() {
        isSpeaking.value = false;
        _onSpeechCompleteCallback?.call();
        _onSpeechCompleteCallback = null;
      });

      _tts.setCancelHandler(() {
        isSpeaking.value = false;
      });

      _tts.setErrorHandler((msg) {
        isSpeaking.value = false;
        debugPrint("TTS Notice: $msg");
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS Init notice: $e");
    }
  }

  /// Speaks autonomously in British English and invokes completion callback.
  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    if (isMuted.value) {
      onComplete?.call();
      return;
    }

    _onSpeechCompleteCallback = onComplete;
    isSpeaking.value = true;

    // 1. Direct Web Speech Synthesis (guaranteed in Edge/Chrome on Web)
    if (kIsWeb) {
      try {
        jsSpeakBritishTeacher(text);
        // Also trigger flutter_tts as fallback
        _tts.speak(text);

        // Approximate timer callback on web to guarantee progression even if event is dropped
        if (onComplete != null) {
          final wordsCount = text.split(' ').length;
          final durationSec = (wordsCount / 2.4).clamp(3.0, 15.0);
          Timer(Duration(seconds: durationSec.round()), () {
            if (_onSpeechCompleteCallback != null) {
              isSpeaking.value = false;
              _onSpeechCompleteCallback?.call();
              _onSpeechCompleteCallback = null;
            }
          });
        }
        return;
      } catch (e) {
        debugPrint("Web JS TTS fallback: $e");
      }
    }

    // 2. Native Desktop / Mobile TTS
    if (!_isInitialized) {
      await _initTts();
    }

    try {
      await _tts.stop();
      await _tts.setLanguage("en-GB");
      await _tts.speak(text);
    } catch (e) {
      debugPrint("TTS Speak fallback: $e");
    }
  }

  /// Stops speech.
  Future<void> stop() async {
    isSpeaking.value = false;
    _onSpeechCompleteCallback = null;
    if (kIsWeb) {
      try {
        jsStopTeacherSpeech();
      } catch (_) {}
    }
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Toggles mute.
  void toggleMute() {
    isMuted.value = !isMuted.value;
    if (isMuted.value) stop();
  }

  void dispose() {
    stop();
    isSpeaking.dispose();
    isMuted.dispose();
  }
}
