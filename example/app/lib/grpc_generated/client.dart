import 'package:grpc/grpc_connection_interface.dart';
// Conditional imports to enable single gRPC client creation for native and Web platfrom
import 'client_native.dart'
    if (dart.library.io) 'client_native.dart'
    if (dart.library.html) 'client_web.dart';

Map<String, ClientChannelBase> _clientChannelMap = {};

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

/// Lazily creates client channel, for each host/port pair there's one channel created and stored internally.
/// You can use this channel to instatiate specigic client, i.e. `MyCleint(getClientChannel())`
/// Parameters:
/// - `host`: The host address. Default value is [defaultHost].
/// - `port`: The port number. If not provided, the [defaultPort] value will be used.
ClientChannelBase getClientChannel({String? host, int? port}) {
  _clientChannelMap['$host:$port'] ??=
      getGrpcClientChannel(host ?? defaultHost, port ?? defaultPort, false);
  return _clientChannelMap['$host:$port']!;
}
