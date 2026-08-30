import 'package:flutter_test/flutter_test.dart';
import 'package:kids_quest/main.dart';

void main() {
  testWidgets('Maestra Jade Logic App renders masterclass UI successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaestraJadeLogicApp());

    // Verify that the title and start overlay are present.
    expect(find.text("Maestra Jade's Masterclass"), findsOneWidget);
    expect(find.text("Start Masterclass 🎬 🇬🇧"), findsOneWidget);
  });
}
