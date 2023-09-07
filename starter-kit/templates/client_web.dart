import 'package:grpc/grpc_connection_interface.dart';
import 'package:grpc/grpc_web.dart';

ClientChannelBase getGrpcClientChannel(String host, int port, bool useHttp) {
  return GrpcWebClientChannel.xhr(
      Uri.parse('http${useHttp ? 's' : ''}://$host:$port'));
}
