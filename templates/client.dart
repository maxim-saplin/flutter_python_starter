import './service.pbgrpc.dart';
// Conditional imports to enable single gRPC client creation for native and Web platfrom
import 'client_native.dart'
    if (dart.library.io) 'client_native.dart'
    if (dart.library.html) 'client_web.dart';

// TODO, replace `NumberSortingServiceClient` with you service client class name

Map<String, NumberSortingServiceClient> _clientMap = {};

/// Lazily creates client, for each host/port pair there's one client created and stored internally
NumberSortingServiceClient getClient({
  String host = 'localhost',
  int port = 50055,
}) {
  _clientMap['$host:$port'] ??=
      NumberSortingServiceClient(getGrpcClientChannel(host, port, false));
  return _clientMap['$host:$port']!;
}
