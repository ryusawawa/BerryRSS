import 'package:flutter/material.dart';

void patchErrorLogging() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print('================ FLUTTER ERROR ================');
    print(details.exceptionAsString());
    print(details.stack);
    print('===============================================');
  };
}
