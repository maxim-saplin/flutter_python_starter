import './service.pbgrpc.dart';
// Conditional imports to enable single gRPC client creation for native and Web platfrom
import 'client_native.dart'
    if (dart.library.io) 'client_native.dart'
    if (dart.library.html) 'client_web.dart';

// TODO, replace `NumberSortingServiceClient` with you service client class name

Map<String, NumberSortingServiceClient> _clientMap = {};

int? _port;

int get defaultPort => _port ?? 50055;

/// Override the default port where the client will attempt to connect
set defaultPort(int? value) {
  _port = value;
}

String _defaultHost = 'localhost';

String get defaultHost => _defaultHost;

/// Set the default host address
set defaultHost(String value) {
  _defaultHost = value;
}

// !You can copy and paste this getClient under different names for each service
/// Lazily creates client, for each host/port pair there's one client created and stored internally
/// Parameters:
/// - `host`: The host address. Default value is [defaultHost].
/// - `port`: The port number. If not provided, the [defaultPort] value will be used.
NumberSortingServiceClient getClient({String? host, int? port}) {
  _clientMap['$host:$port'] ??= NumberSortingServiceClient(
      getGrpcClientChannel(host ?? defaultHost, port ?? defaultPort, false));
  return _clientMap['$host:$port']!;
}
