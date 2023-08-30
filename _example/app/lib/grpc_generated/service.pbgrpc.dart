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

@$pb.GrpcServiceName('NumberSortingService')
class NumberSortingServiceClient extends $grpc.Client {
  static final _$sortNumbers = $grpc.ClientMethod<$0.NumberArray, $0.NumberArray>(
      '/NumberSortingService/SortNumbers',
      ($0.NumberArray value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.NumberArray.fromBuffer(value));

  NumberSortingServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.NumberArray> sortNumbers($0.NumberArray request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sortNumbers, request, options: options);
  }
}

@$pb.GrpcServiceName('NumberSortingService')
abstract class NumberSortingServiceBase extends $grpc.Service {
  $core.String get $name => 'NumberSortingService';

  NumberSortingServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.NumberArray, $0.NumberArray>(
        'SortNumbers',
        sortNumbers_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.NumberArray.fromBuffer(value),
        ($0.NumberArray value) => value.writeToBuffer()));
  }

  $async.Future<$0.NumberArray> sortNumbers_Pre($grpc.ServiceCall call, $async.Future<$0.NumberArray> request) async {
    return sortNumbers(call, await request);
  }

  $async.Future<$0.NumberArray> sortNumbers($grpc.ServiceCall call, $0.NumberArray request);
}
