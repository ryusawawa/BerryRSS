import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:berry_rss/main.dart' as app;

void main() {
  testWidgets('App launch and initial render test', (WidgetTester tester) async {
    // 描画エラーが発生したときに即座にテストログに詳細を出力する
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('================= DETECTED EXCEPTION =================');
      debugPrint(details.exceptionAsString());
      debugPrint(details.stack.toString());
      debugPrint('======================================================');
    };

    // main() を呼び出して画面描画を開始
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
