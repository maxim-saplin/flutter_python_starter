import 'init_py_native.dart'
    if (dart.library.io) 'init_py_native.dart'
    if (dart.library.html) 'init_py_web.dart';

Future<void> initPy() async {
  return initPyImpl();
}
