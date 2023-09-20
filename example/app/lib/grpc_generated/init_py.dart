import 'package:app/grpc_generated/health.pbgrpc.dart';
import 'package:flutter/foundation.dart';

import 'client.dart';
import 'init_py_native.dart'
    if (dart.library.io) 'init_py_native.dart'
    if (dart.library.html) 'init_py_web.dart';

bool localPyStartSkipped = false;

/// Initialize Python part, start self-hosted server for desktop, await for local
/// or remote gRPC server to respond. If no response is resived within 15 second
/// exception is thrown.
/// Set [doNotStartPy] to `true` if you would like to use remote server
Future<void> initPy([bool doNoStartPy = false]) async {
  _initParamsFromEnvVars(doNoStartPy);

  // Launch self-hosted servr or do nothing
  await (localPyStartSkipped ? Future(() => null) : initPyImpl());

  await _waitForServer();
}

Future<void> _waitForServer() async {
  var cleint = HealthClient(getClientChannel());
  var request = HealthCheckRequest();
  var started = false;

  for (var i = 0; i < 30; i++) {
    try {
      var r = await cleint.check(request);

      if (r.status == HealthCheckResponse_ServingStatus.SERVING) {
        started = true;
        break;
      }
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  if (!started) {
    throw "Can't connect to gRPC server";
  }
}

void _initParamsFromEnvVars(bool doNoStartPy) {
  // Hack to get access to --dart-define values in the web https://stackoverflow.com/questions/65647090/access-dart-define-environment-variables-inside-index-html
  if (kIsWeb) {
    initPyImpl();
  }

  var flag = const String.fromEnvironment('useRemote', defaultValue: 'false') ==
      'true';
  if (doNoStartPy || flag) {
    localPyStartSkipped = true;
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
}

/// Searches for any processes that match Python server and kills those.
/// Does nothing in the Web environment.
Future<void> shutdownPyIfAny() {
  return shutdownPyIfAnyImpl();
}
