import '../models/curriculum_models.dart';

/// Comprehensive Question Bank across Easy, Medium, Hard, and Challenge tiers.
class QuestionBank {
  static const List<ComprehensiveQuestion> allQuestions = [
    // ==========================================
    // TIER 1: EASY (Foundational Patterns & AB Chains)
    // ==========================================
    ComprehensiveQuestion(
      id: 'easy_q1_ab_shapes',
      conceptId: 'concept_ab_rhythm',
      type: QuestionType.sequencePattern,
      difficulty: DifficultyLevel.easy,
      sequenceItems: ['🔺', '🟦', '🔺', '🟦', '🔺', '❓'],
      question: "Which shape completes the alternating chain: 🔺 ➔ 🟦 ➔ 🔺 ➔ 🟦 ➔ 🔺 ➔ [ ? ]",
      spokenPrompt: "Which shape completes the alternating pattern?",
      options: ['🟦 Blue Square', '🔺 Red Triangle', '🟡 Yellow Circle', '⭐ Gold Star'],
      correctIndex: 0,
      explanation: "The pattern alternates between Triangle and Square. After a Triangle, a Square always follows.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Look at the shape right before the question mark.", spokenGuidance: "Look at the shape right before the question mark!"),
        ProgressiveHint(level: 2, hintText: "Every Triangle is paired with a Blue Square.", spokenGuidance: "Notice that every Triangle is followed by a Blue Square!"),
        ProgressiveHint(level: 3, hintText: "The core unit is [🔺 + 🟦]. The missing shape is 🟦.", spokenGuidance: "The repeating pair is Triangle then Square, so Blue Square completes it!"),
      ],
      skillsTested: ['AB Alternation', 'Visual Core Extraction'],
    ),

    ComprehensiveQuestion(
      id: 'easy_q2_leap_two',
      conceptId: 'concept_skip_counting',
      type: QuestionType.numberGrowth,
      difficulty: DifficultyLevel.easy,
      sequenceItems: ['2', '4', '6', '8', '❓'],
      question: "What number comes next in the skip-counting jump: 2 ➔ 4 ➔ 6 ➔ 8 ➔ [ ? ]",
      spokenPrompt: "What number completes the plus two jump?",
      options: ['10 (Ten)', '9 (Nine)', '12 (Twelve)', '7 (Seven)'],
      correctIndex: 0,
      explanation: "Every step adds 2. 8 + 2 = 10.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Count by twos: 2, 4, 6, 8...", spokenGuidance: "Count along with me: 2, 4, 6, 8..."),
        ProgressiveHint(level: 2, hintText: "Add plus two to the number 8.", spokenGuidance: "What is eight plus two?"),
        ProgressiveHint(level: 3, hintText: "8 + 2 = 10.", spokenGuidance: "Eight plus two equals ten!"),
      ],
      skillsTested: ['Skip Counting by 2', 'Additive Progression'],
    ),

    ComprehensiveQuestion(
      id: 'easy_q3_abc_colors',
      conceptId: 'concept_trio_rhythm',
      type: QuestionType.sequencePattern,
      difficulty: DifficultyLevel.easy,
      sequenceItems: ['🔴', '🟢', '🟡', '🔴', '🟢', '❓'],
      question: "Complete the color trio sequence: 🔴 ➔ 🟢 ➔ 🟡 ➔ 🔴 ➔ 🟢 ➔ [ ? ]",
      spokenPrompt: "Which colored circle finishes the three-color cycle?",
      options: ['🟡 Yellow Circle', '🔴 Red Circle', '🟣 Purple Circle', '🟢 Green Circle'],
      correctIndex: 0,
      explanation: "The repeating trio unit is [Red, Green, Yellow]. Yellow completes the second loop.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Say the colors in rhythm: Red, Green, Yellow...", spokenGuidance: "Chant the rhythm: Red, Green, Yellow..."),
        ProgressiveHint(level: 2, hintText: "Look at the first group: Red, Green, then Yellow.", spokenGuidance: "After Red and Green comes Yellow!"),
        ProgressiveHint(level: 3, hintText: "The third element of the trio is Yellow Circle.", spokenGuidance: "Yellow Circle finishes the sequence!"),
      ],
      skillsTested: ['ABC Rhythm', 'Trio Cycle'],
    ),

    ComprehensiveQuestion(
      id: 'easy_q4_day_night',
      conceptId: 'concept_natural_cycles',
      type: QuestionType.sequencePattern,
      difficulty: DifficultyLevel.easy,
      sequenceItems: ['☀️', '🌙', '☀️', '🌙', '☀️', '❓'],
      question: "What follows the bright sun: ☀️ ➔ 🌙 ➔ ☀️ ➔ 🌙 ➔ ☀️ ➔ [ ? ]",
      spokenPrompt: "What appears in the sky next?",
      options: ['🌙 Crescent Moon', '☀️ Bright Sun', '⚡ Thunder Cloud', '🌈 Rainbow'],
      correctIndex: 0,
      explanation: "The sky alternates between Day (Sun) and Night (Moon).",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "What shines in the sky after daytime?", spokenGuidance: "What shines in the sky when the sun sets?"),
        ProgressiveHint(level: 2, hintText: "Sun is always followed by the Moon.", spokenGuidance: "Sun leads to Moon!"),
        ProgressiveHint(level: 3, hintText: "The Moon 🌙 completes the cycle.", spokenGuidance: "The Crescent Moon completes the cycle!"),
      ],
      skillsTested: ['Natural Cycles', 'Binary Alternation'],
    ),

    ComprehensiveQuestion(
      id: 'easy_q5_growth_stages',
      conceptId: 'concept_progression_order',
      type: QuestionType.ordering,
      difficulty: DifficultyLevel.easy,
      sequenceItems: ['🌱 Sprout', '🌿 Plant', '🌳 Tree', '🌱 Sprout', '🌿 Plant', '❓'],
      question: "Complete the nature growth cycle: 🌱 ➔ 🌿 ➔ 🌳 ➔ 🌱 ➔ 🌿 ➔ [ ? ]",
      spokenPrompt: "What full-grown plant completes the cycle?",
      options: ['🌳 Grand Tree', '🌱 Tiny Sprout', '🍂 Dry Leaf', '🍄 Mushroom'],
      correctIndex: 0,
      explanation: "A sprout grows into a plant, which blooms into a grand tree.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "How does a tiny seed grow into its tallest form?", spokenGuidance: "How does a little sprout grow tall?"),
        ProgressiveHint(level: 2, hintText: "Look at what comes after the leafy plant in the first set.", spokenGuidance: "After the plant comes the grand tree!"),
        ProgressiveHint(level: 3, hintText: "The Grand Tree 🌳 completes the growth trio.", spokenGuidance: "The Grand Tree completes the growth trio!"),
      ],
      skillsTested: ['Biological Sequencing', 'Lifecycle Deductions'],
    ),

    // ==========================================
    // TIER 2: MEDIUM (Growing Patterns & Logic Reasoning)
    // ==========================================
    ComprehensiveQuestion(
      id: 'med_q1_aab_rhythm',
      conceptId: 'concept_aab_core',
      type: QuestionType.shapePattern,
      difficulty: DifficultyLevel.medium,
      sequenceItems: ['⭐', '⭐', '💎', '⭐', '⭐', '❓'],
      question: "Identify the AAB pattern rule: ⭐ ➔ ⭐ ➔ 💎 ➔ ⭐ ➔ ⭐ ➔ [ ? ]",
      spokenPrompt: "Which treasure finishes this AAB pattern?",
      options: ['💎 Crystal Diamond', '⭐ Gold Star', '🪙 Gold Coin', '👑 Royal Crown'],
      correctIndex: 0,
      explanation: "The core unit is [Star, Star, Diamond]. After two Stars comes a Diamond.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Notice that Stars appear in pairs of two.", spokenGuidance: "Stars always travel in pairs of two!"),
        ProgressiveHint(level: 2, hintText: "After two Stars, what special jewel appears?", spokenGuidance: "After two stars, which jewel appears?"),
        ProgressiveHint(level: 3, hintText: "The Crystal Diamond 💎 finishes the [Star, Star, Diamond] rule.", spokenGuidance: "The Crystal Diamond finishes the rule!"),
      ],
      skillsTested: ['AAB Pattern Recognition', 'Grouping Detection'],
    ),

    ComprehensiveQuestion(
      id: 'med_q2_leap_five',
      conceptId: 'concept_skip_counting',
      type: QuestionType.numberGrowth,
      difficulty: DifficultyLevel.medium,
      sequenceItems: ['5', '10', '15', '20', '❓'],
      question: "Calculate the next leap in the fives sequence: 5 ➔ 10 ➔ 15 ➔ 20 ➔ [ ? ]",
      spokenPrompt: "What number comes next when counting by fives?",
      options: ['25 (Twenty-Five)', '30 (Thirty)', '22 (Twenty-Two)', '24 (Twenty-Four)'],
      correctIndex: 0,
      explanation: "Each step adds 5. 20 + 5 = 25.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Count by fives on your hands: 5, 10, 15, 20...", spokenGuidance: "Count by fives: 5, 10, 15, 20..."),
        ProgressiveHint(level: 2, hintText: "Add 5 to 20.", spokenGuidance: "What is twenty plus five?"),
        ProgressiveHint(level: 3, hintText: "20 + 5 = 25.", spokenGuidance: "Twenty plus five equals twenty-five!"),
      ],
      skillsTested: ['Skip Counting by 5', 'Multiples of 5'],
    ),

    ComprehensiveQuestion(
      id: 'med_q3_odd_one_out_shapes',
      conceptId: 'concept_classification',
      type: QuestionType.oddOneOut,
      difficulty: DifficultyLevel.medium,
      sequenceItems: ['🔺 (3 sides)', '🟦 (4 sides)', '⬠ (5 sides)', '🔴 (Round)'],
      question: "Which shape is the Odd One Out that does NOT have straight edges?",
      spokenPrompt: "Which shape has curved edges instead of straight corners?",
      options: ['🔴 Red Circle', '🔺 Triangle', '🟦 Square', '⬠ Pentagon'],
      correctIndex: 0,
      explanation: "The Circle has no straight sides or sharp vertices, while all others are polygons.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Look at the sides and corners of each shape.", spokenGuidance: "Count the straight sides and corners!"),
        ProgressiveHint(level: 2, hintText: "Polygons have straight edges; circles are completely curved.", spokenGuidance: "Which shape is completely curved without corners?"),
        ProgressiveHint(level: 3, hintText: "🔴 Red Circle is round with zero straight edges.", spokenGuidance: "The Red Circle is round and has zero straight sides!"),
      ],
      skillsTested: ['Geometric Classification', 'Attribute Comparison'],
    ),

    ComprehensiveQuestion(
      id: 'med_q4_expanding_stairs',
      conceptId: 'concept_expanding_patterns',
      type: QuestionType.shapePattern,
      difficulty: DifficultyLevel.medium,
      sequenceItems: ['🟩 (1)', '🟩🟩 (2)', '🟩🟩🟩 (3)', '❓'],
      question: "How many green blocks build the next stair step: 1 ➔ 2 ➔ 3 ➔ [ ? ]",
      spokenPrompt: "How many blocks come in the fourth step of the staircase?",
      options: ['🟩🟩🟩🟩 (4 Blocks)', '🟩🟩🟩🟩🟩 (5 Blocks)', '🟩🟩 (2 Blocks)', '🟩🟩🟩 (3 Blocks)'],
      correctIndex: 0,
      explanation: "The blocks increase by 1 at each step: 1, 2, 3, 4 blocks.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Count how many blocks are added each time.", spokenGuidance: "How many blocks are added at each step?"),
        ProgressiveHint(level: 2, hintText: "Step 1 has 1, Step 2 has 2, Step 3 has 3...", spokenGuidance: "Step 1 has one, Step 2 has two, Step 3 has three..."),
        ProgressiveHint(level: 3, hintText: "Step 4 must have exactly 4 blocks.", spokenGuidance: "Step four has four blocks!"),
      ],
      skillsTested: ['Growing Patterns', 'Linear Addition'],
    ),

    ComprehensiveQuestion(
      id: 'med_q5_clock_rotation',
      conceptId: 'concept_rotational_patterns',
      type: QuestionType.visualDeduction,
      difficulty: DifficultyLevel.medium,
      sequenceItems: ['⬆️ Up', '➡️ Right', '⬇️ Down', '❓'],
      question: "Which compass arrow completes the clockwise spin: ⬆️ ➔ ➡️ ➔ ⬇️ ➔ [ ? ]",
      spokenPrompt: "Which direction does the arrow turn next following the clock?",
      options: ['⬅️ Left', '⬆️ Up', '↗️ Top-Right', '🔄 Spin Circle'],
      correctIndex: 0,
      explanation: "The arrow rotates 90 degrees clockwise at each step: Up, Right, Down, Left.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Follow the hands of a clock spinning clockwise.", spokenGuidance: "Follow the spin of clock hands around a circle!"),
        ProgressiveHint(level: 2, hintText: "Up turns to Right, Right turns to Down...", spokenGuidance: "Up turns to Right, Right turns to Down, Down turns to..."),
        ProgressiveHint(level: 3, hintText: "After Down comes ⬅️ Left.", spokenGuidance: "After pointing Down, the arrow turns Left!"),
      ],
      skillsTested: ['Spatial Reasoning', 'Rotational Symmetry'],
    ),

    // ==========================================
    // TIER 3: HARD (Complex Rules, Doubling & Deductions)
    // ==========================================
    ComprehensiveQuestion(
      id: 'hard_q1_doubling_powers',
      conceptId: 'concept_geometric_growth',
      type: QuestionType.numberGrowth,
      difficulty: DifficultyLevel.hard,
      sequenceItems: ['1', '2', '4', '8', '16', '❓'],
      question: "Discover the secret growth rule: 1 ➔ 2 ➔ 4 ➔ 8 ➔ 16 ➔ [ ? ]",
      spokenPrompt: "What is double sixteen in this multiplying growth chain?",
      options: ['32 (Thirty-Two)', '24 (Twenty-Four)', '30 (Thirty)', '64 (Sixty-Four)'],
      correctIndex: 0,
      explanation: "Every number doubles (multiplies by 2). 16 x 2 = 32.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Look at the leap between numbers: 1 to 2, 2 to 4, 4 to 8...", spokenGuidance: "Each number is being doubled!"),
        ProgressiveHint(level: 2, hintText: "Double means multiplying by 2. What is 16 + 16?", spokenGuidance: "What is sixteen plus sixteen?"),
        ProgressiveHint(level: 3, hintText: "16 x 2 = 32.", spokenGuidance: "Sixteen times two equals thirty-two!"),
      ],
      skillsTested: ['Doubling Rule', 'Exponential Growth'],
    ),

    ComprehensiveQuestion(
      id: 'hard_q2_alternating_operators',
      conceptId: 'concept_compound_rules',
      type: QuestionType.logicalReasoning,
      difficulty: DifficultyLevel.hard,
      sequenceItems: ['1 (+3)➔', '4 (-1)➔', '3 (+3)➔', '6 (-1)➔', '5 (+3)➔', '❓'],
      question: "Deduce the two alternating math operations (+3, -1): 1, 4, 3, 6, 5, [ ? ]",
      spokenPrompt: "What is five plus three in this alternating math sequence?",
      options: ['8 (Eight)', '7 (Seven)', '9 (Nine)', '4 (Four)'],
      correctIndex: 0,
      explanation: "The operations alternate: +3, -1, +3, -1, +3. 5 + 3 = 8.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Look at how the numbers jump up, then drop down.", spokenGuidance: "The pattern jumps up by three, then drops down by one!"),
        ProgressiveHint(level: 2, hintText: "After 5, the next step is +3.", spokenGuidance: "Add three to the number five!"),
        ProgressiveHint(level: 3, hintText: "5 + 3 = 8.", spokenGuidance: "Five plus three equals eight!"),
      ],
      skillsTested: ['Two-Step Compound Rules', 'Arithmetic Logic'],
    ),

    ComprehensiveQuestion(
      id: 'hard_q3_matrix_deduction',
      conceptId: 'concept_matrix_reasoning',
      type: QuestionType.visualDeduction,
      difficulty: DifficultyLevel.hard,
      sequenceItems: ['[ 🔴 🔺 ]', '[ 🔴 🟦 ]', '[ 🟡 🔺 ]', '[ 🟡 ❓ ]'],
      question: "Complete the 2x2 logic matrix: Row 1 is Red, Row 2 is Yellow. Col 1 is Triangle, Col 2 is Square.",
      spokenPrompt: "What shape finishes the yellow row and square column?",
      options: ['🟦 Yellow Square', '🔺 Yellow Triangle', '🔴 Red Square', '⭐ Yellow Star'],
      correctIndex: 0,
      explanation: "Row 2 uses Yellow shapes and Column 2 uses Squares, creating a Yellow Square.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Match the row color (Yellow) with the column shape (Square).", spokenGuidance: "Match the row color with the column shape!"),
        ProgressiveHint(level: 2, hintText: "Row 2 has yellow shapes. Column 2 has squares.", spokenGuidance: "Row two has yellow shapes. Column two has squares."),
        ProgressiveHint(level: 3, hintText: "The intersection is 🟦 Yellow Square.", spokenGuidance: "Yellow Square completes the matrix!"),
      ],
      skillsTested: ['Matrix Reasoning', 'Multi-Variable Intersection'],
    ),

    ComprehensiveQuestion(
      id: 'hard_q4_fibonacci_steps',
      conceptId: 'concept_additive_recurrence',
      type: QuestionType.numberGrowth,
      difficulty: DifficultyLevel.hard,
      sequenceItems: ['1', '1', '2', '3', '5', '8', '❓'],
      question: "Deduce the famous nature sequence: add the previous two numbers together to find the next!",
      spokenPrompt: "What is five plus eight in this famous nature sequence?",
      options: ['13 (Thirteen)', '11 (Eleven)', '15 (Fifteen)', '16 (Sixteen)'],
      correctIndex: 0,
      explanation: "Each number is the sum of the two preceding numbers: 5 + 8 = 13 (Fibonacci sequence).",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "1+1=2, 1+2=3, 2+3=5, 3+5=8...", spokenGuidance: "Add each pair of neighbor numbers together!"),
        ProgressiveHint(level: 2, hintText: "Add the last two numbers: 5 + 8.", spokenGuidance: "What is five plus eight?"),
        ProgressiveHint(level: 3, hintText: "5 + 8 = 13.", spokenGuidance: "Five plus eight equals thirteen!"),
      ],
      skillsTested: ['Recurrent Addition', 'Pattern Synthesis'],
    ),

    // ==========================================
    // TIER 4: CHALLENGE (Master Logician Puzzles)
    // ==========================================
    ComprehensiveQuestion(
      id: 'chal_q1_transitive_logic',
      conceptId: 'concept_deductive_logic',
      type: QuestionType.logicalReasoning,
      difficulty: DifficultyLevel.challenge,
      sequenceItems: ['🦁 > 🐺 (Lion is faster than Wolf)', '🐺 > 🦊 (Wolf is faster than Fox)', '❓ Who is fastest?'],
      question: "If the Lion is faster than the Wolf, and the Wolf is faster than the Fox, who is the fastest of all?",
      spokenPrompt: "Who is the fastest runner among the three animals?",
      options: ['🦁 Lion', '🐺 Wolf', '🦊 Fox', '🤝 All are equal'],
      correctIndex: 0,
      explanation: "By transitive logic: Lion > Wolf > Fox, so the Lion is the fastest overall.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "The Lion beats the Wolf, and the Wolf beats the Fox.", spokenGuidance: "The Lion beats the Wolf, and the Wolf beats the Fox!"),
        ProgressiveHint(level: 2, hintText: "Can the Fox beat the Lion? No, because Wolf is faster than Fox.", spokenGuidance: "Line them up from fastest to slowest!"),
        ProgressiveHint(level: 3, hintText: "🦁 Lion is at the very top of the speed chain.", spokenGuidance: "The Lion is at the top of the chain!"),
      ],
      skillsTested: ['Transitive Deduction', 'Relational Logic'],
    ),

    ComprehensiveQuestion(
      id: 'chal_q2_square_numbers',
      conceptId: 'concept_quadratic_geometry',
      type: QuestionType.numberGrowth,
      difficulty: DifficultyLevel.challenge,
      sequenceItems: ['1x1 = 1', '2x2 = 4', '3x3 = 9', '4x4 = 16', '❓ 5x5 = ?'],
      question: "Square Number Puzzle: 1, 4, 9, 16, [ ? ]. What is the area of a 5 by 5 square grid?",
      spokenPrompt: "What is five times five in this square grid progression?",
      options: ['25 (Twenty-Five)', '20 (Twenty)', '30 (Thirty)', '36 (Thirty-Six)'],
      correctIndex: 0,
      explanation: "These are square numbers (n^2): 1, 4, 9, 16, 25. 5 x 5 = 25.",
      progressiveHints: [
        ProgressiveHint(level: 1, hintText: "Multiply the step number by itself!", spokenGuidance: "Multiply each step number by itself!"),
        ProgressiveHint(level: 2, hintText: "For step 5, compute 5 multiplied by 5.", spokenGuidance: "What is five times five?"),
        ProgressiveHint(level: 3, hintText: "5 x 5 = 25.", spokenGuidance: "Five times five equals twenty-five!"),
      ],
      skillsTested: ['Geometric Square Numbers', 'Spatial Grid Multiplication'],
    ),
  ];

  /// Filter questions by difficulty tier.
  static List<ComprehensiveQuestion> getQuestionsForDifficulty(DifficultyLevel difficulty) {
    return allQuestions.where((q) => q.difficulty == difficulty).toList();
  }

  /// Adaptive selector based on student's current mastery & streak.
  static ComprehensiveQuestion selectNextAdaptiveQuestion({
    required DifficultyLevel currentDifficulty,
    required List<String> recentQuestionIds,
  }) {
    final candidateList = allQuestions.where((q) => q.difficulty == currentDifficulty).toList();
    final unaskedCandidates = candidateList.where((q) => !recentQuestionIds.contains(q.id)).toList();

    if (unaskedCandidates.isNotEmpty) {
      return unaskedCandidates.first;
    }
    return candidateList.first;
  }
}
