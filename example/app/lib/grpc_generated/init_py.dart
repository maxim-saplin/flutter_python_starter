import 'client.dart';
import 'init_py_native.dart'
    if (dart.library.io) 'init_py_native.dart'
    if (dart.library.html) 'init_py_web.dart';

bool localPyStartSkipped = false;

/// Set [doNotStartPy] to `true` if you would like to use remote server
Future<void> initPy([bool doNoStartPy = false]) async {
  var flag = const String.fromEnvironment('useRemote', defaultValue: 'false') ==
      'true';
  if (doNoStartPy || flag) {
    localPyStartSkipped = true;
    return Future(() => null);
  }

  var hostOverride = const String.fromEnvironment('host', defaultValue: '');
  if (hostOverride.isNotEmpty) {
    defaultHost = hostOverride;
  }

  var portOverride =
      int.tryParse(const String.fromEnvironment('port', defaultValue: ''));
  if (portOverride != null) {
    defaultPort = portOverride;
  }
  return initPyImpl();
}
