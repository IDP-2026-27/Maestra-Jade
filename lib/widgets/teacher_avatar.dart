import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/curriculum_models.dart';

/// Semantic Avatar states mapping for Rive / State Machine integration.
const Map<String, String> avatarStateTriggers = {
  'idle': 'Idle',
  'talking': 'Talking',
  'explaining': 'Explain',
  'pointing': 'Pointing',
  'thinking': 'Thinking',
  'happy': 'Happy',
  'excited': 'Excited',
  'confused': 'Confused',
  'celebrate': 'Celebrate',
  'sad': 'Sad',
};

/// High-fidelity, state-driven animated Avatar Controller for Maestra Jade.
/// Coordinates breathing, talking mouth/body gestures, and pose transitions.
class TeacherAvatar extends StatefulWidget {
  final AvatarAnimationState state;
  final AvatarEmotion emotion;
  final bool isSpeaking;
  final String teacherName;

  const TeacherAvatar({
    super.key,
    this.state = AvatarAnimationState.idle,
    this.emotion = AvatarEmotion.encouraging,
    this.isSpeaking = false,
    this.teacherName = 'Maestra Jade',
  });

  @override
  State<TeacherAvatar> createState() => _TeacherAvatarState();
}

class _TeacherAvatarState extends State<TeacherAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _breathAnim;
  late Animation<double> _gestureAnim;
  late Animation<double> _mouthAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _breathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    _gestureAnim = Tween<double>(begin: -0.04, end: 0.04).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutQuad),
    );

    _mouthAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Selects the appropriate character pose asset based on state and emotion.
  String _selectPoseAsset() {
    if (widget.state == AvatarAnimationState.celebrate ||
        widget.state == AvatarAnimationState.excited ||
        widget.emotion == AvatarEmotion.celebratory) {
      return 'assets/jade_celebrating.png';
    } else if (widget.state == AvatarAnimationState.explaining ||
        widget.state == AvatarAnimationState.pointing) {
      return 'assets/jade_teaching.png';
    } else {
      return 'assets/green_girl.png';
    }
  }

  Color _getMoodGlowColor() {
    switch (widget.state) {
      case AvatarAnimationState.celebrate:
      case AvatarAnimationState.happy:
      case AvatarAnimationState.excited:
        return const Color(0xFF00B894); // Emerald Green
      case AvatarAnimationState.confused:
      case AvatarAnimationState.sad:
        return const Color(0xFFE17055); // Amber Clue
      case AvatarAnimationState.thinking:
        return const Color(0xFF6C5CE7); // Deep Purple
      case AvatarAnimationState.explaining:
      case AvatarAnimationState.pointing:
      case AvatarAnimationState.talking:
        return const Color(0xFF10AC84); // Jade
      case AvatarAnimationState.idle:
        return const Color(0xFF00CEC9); // Bright Cyan
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAsset = _selectPoseAsset();
    final glowColor = _getMoodGlowColor();

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final breathOffset = widget.isSpeaking
            ? math.sin(_animController.value * math.pi * 3) * 4.0
            : _breathAnim.value * 3.0;

        final gestureRotation = widget.isSpeaking
            ? _gestureAnim.value * 0.7
            : (widget.state == AvatarAnimationState.thinking ? -0.03 : 0.0);

        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 280),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ambient Mood Glow Aura
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 190 + (widget.isSpeaking ? 12 : 0),
                height: 190 + (widget.isSpeaking ? 12 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: glowColor.withValues(alpha: widget.isSpeaking ? 0.22 : 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: widget.isSpeaking ? 0.35 : 0.15),
                      blurRadius: widget.isSpeaking ? 30 : 15,
                    ),
                  ],
                ),
              ),

              // Animated Character Rendering with natural micro-dynamics
              Transform.translate(
                offset: Offset(0, -breathOffset),
                child: Transform.rotate(
                  angle: gestureRotation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Image.asset(
                      activeAsset,
                      fit: BoxFit.contain,
                      semanticLabel:
                          '${widget.teacherName} in ${widget.state.stateName} state (${widget.emotion.name})',
                    ),
                  ),
                ),
              ),

              // Active Speaking / Rhythm Equalizer Pill
              if (widget.isSpeaking)
                Positioned(
                  top: 14,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10AC84), Color(0xFF00CEC9)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10AC84).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 4 + (_mouthAnim.value * 4),
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.graphic_eq_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          "Speaking 🇬🇧",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Semantic State Label Pill
              Positioned(
                top: 14,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: glowColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.state == AvatarAnimationState.celebrate
                            ? Icons.stars_rounded
                            : widget.state == AvatarAnimationState.thinking
                                ? Icons.psychology_rounded
                                : Icons.lightbulb_rounded,
                        size: 13,
                        color: glowColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.state.stateName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: glowColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Teacher Name Badge
              Positioned(
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D1457),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF00CEC9), size: 14),
                      const SizedBox(width: 5),
                      Text(
                        widget.teacherName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
