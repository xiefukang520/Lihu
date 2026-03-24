import 'package:flutter_test/flutter_test.dart';

import 'package:test_project/main.dart';

void main() {
  testWidgets('email login page renders core texts', (WidgetTester tester) async {
    await tester.pumpWidget(const TestProjectApp());
    await tester.pumpAndSettle();

    expect(find.text('邮箱登陆'), findsOneWidget);
    expect(find.text('邮箱号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('完成'), findsOneWidget);
  });
}
