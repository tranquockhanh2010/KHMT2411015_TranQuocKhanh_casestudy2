import 'package:flutter_test/flutter_test.dart';

import 'package:casestudy2/main.dart';

void main() {
  testWidgets('shows the login screen before authentication', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Đăng nhập'), findsNWidgets(2));
    expect(find.text('Chưa có tài khoản? Đăng ký'), findsOneWidget);
  });
}
