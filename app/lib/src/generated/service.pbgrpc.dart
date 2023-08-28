//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'service.pb.dart' as $0;

export 'service.pb.dart';

@$pb.GrpcServiceName('MathOperations')
class MathOperationsClient extends $grpc.Client {
  static final _$matrixMultiply = $grpc.ClientMethod<$0.MatrixRequest, $0.MatrixResponse>(
      '/MathOperations/MatrixMultiply',
      ($0.MatrixRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.MatrixResponse.fromBuffer(value));

  MathOperationsClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.MatrixResponse> matrixMultiply($0.MatrixRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$matrixMultiply, request, options: options);
  }
}

@$pb.GrpcServiceName('MathOperations')
abstract class MathOperationsServiceBase extends $grpc.Service {
  $core.String get $name => 'MathOperations';

  MathOperationsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.MatrixRequest, $0.MatrixResponse>(
        'MatrixMultiply',
        matrixMultiply_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.MatrixRequest.fromBuffer(value),
        ($0.MatrixResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.MatrixResponse> matrixMultiply_Pre($grpc.ServiceCall call, $async.Future<$0.MatrixRequest> request) async {
    return matrixMultiply(call, await request);
  }

  $async.Future<$0.MatrixResponse> matrixMultiply($grpc.ServiceCall call, $0.MatrixRequest request);
}
