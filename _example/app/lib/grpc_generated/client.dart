import './service.pbgrpc.dart';
// Conditional imports to enable single gRPC client creation for native and Web platfrom
import 'client_native.dart'
    if (dart.library.io) 'client_native.dart'
    if (dart.library.html) 'client_web.dart';

NumberSortingServiceClient? _client;

NumberSortingServiceClient get client {
  _client ??= NumberSortingServiceClient(
      getGrpcClientChannel('127.0.0.1', 50555, false));
  return _client!;
}
