//
//  Generated code. Do not modify.
//  source: service.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MatrixRequest extends $pb.GeneratedMessage {
  factory MatrixRequest({
    $core.Iterable<$core.double>? values,
    $core.int? columns,
  }) {
    final $result = create();
    if (values != null) {
      $result.values.addAll(values);
    }
    if (columns != null) {
      $result.columns = columns;
    }
    return $result;
  }
  MatrixRequest._() : super();
  factory MatrixRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatrixRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatrixRequest', createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'values', $pb.PbFieldType.KD)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'columns', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatrixRequest clone() => MatrixRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatrixRequest copyWith(void Function(MatrixRequest) updates) => super.copyWith((message) => updates(message as MatrixRequest)) as MatrixRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixRequest create() => MatrixRequest._();
  MatrixRequest createEmptyInstance() => create();
  static $pb.PbList<MatrixRequest> createRepeated() => $pb.PbList<MatrixRequest>();
  @$core.pragma('dart2js:noInline')
  static MatrixRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatrixRequest>(create);
  static MatrixRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.double> get values => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get columns => $_getIZ(1);
  @$pb.TagNumber(2)
  set columns($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasColumns() => $_has(1);
  @$pb.TagNumber(2)
  void clearColumns() => clearField(2);
}

class MatrixResponse extends $pb.GeneratedMessage {
  factory MatrixResponse({
    $core.Iterable<$core.double>? values,
  }) {
    final $result = create();
    if (values != null) {
      $result.values.addAll(values);
    }
    return $result;
  }
  MatrixResponse._() : super();
  factory MatrixResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatrixResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatrixResponse', createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'values', $pb.PbFieldType.KD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatrixResponse clone() => MatrixResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatrixResponse copyWith(void Function(MatrixResponse) updates) => super.copyWith((message) => updates(message as MatrixResponse)) as MatrixResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixResponse create() => MatrixResponse._();
  MatrixResponse createEmptyInstance() => create();
  static $pb.PbList<MatrixResponse> createRepeated() => $pb.PbList<MatrixResponse>();
  @$core.pragma('dart2js:noInline')
  static MatrixResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatrixResponse>(create);
  static MatrixResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.double> get values => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
