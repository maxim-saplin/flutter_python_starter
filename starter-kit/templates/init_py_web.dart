// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<void> initPyImpl() async {
  // Fire event pushing env variables to Dart
  html.document.dispatchEvent(html.CustomEvent("dart_loaded"));
}
