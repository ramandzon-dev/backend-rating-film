import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rating_film/main.dart';

void main() {
  testWidgets('App renders FilmRatingApp successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const FilmRatingApp());
    expect(find.text('Film Rating'), findsOneWidget);
  });
}
