import 'init_py_native.dart'
    if (dart.library.io) 'init_py_native.dart'
    if (dart.library.html) 'init_py_web.dart';

/// Set [doNotStartPy] to `true` if you would like to use remote server
Future<void> initPy([bool doNoStartPy = false]) async {
  if (doNoStartPy) return Future(() => null);
  return initPyImpl();
}
