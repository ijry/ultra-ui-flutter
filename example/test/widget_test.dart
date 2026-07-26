import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_example/app/example_app.dart';

void main() {
  testWidgets('UltraUiExampleApp boots the source component destination',
      (tester) async {
    await tester.pumpWidget(const UltraUiExampleApp());

    expect(find.text('uview-plus'), findsOneWidget);
    expect(find.text('组件'), findsWidgets);
    expect(find.text('模板'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
