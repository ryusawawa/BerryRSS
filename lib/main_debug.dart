import 'dart:async';
import 'package:flutter/material.dart';

void setupLogging() {
  FlutterError.onError = (FlutterErrorDetails details) {
    print('==== FLUTTER ERROR ====');
    print(details.exceptionAsString());
    print(details.stack);
  };
}
