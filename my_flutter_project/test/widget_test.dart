import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_project/main.dart';

void main() {
  testWidgets('Recycling dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(const RecyclingApp());

    expect(find.text('Plastic Recycling'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
  });
}