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

class NumberArray extends $pb.GeneratedMessage {
  factory NumberArray({
    $core.Iterable<$core.int>? numbers,
  }) {
    final $result = create();
    if (numbers != null) {
      $result.numbers.addAll(numbers);
    }
    return $result;
  }
  NumberArray._() : super();
  factory NumberArray.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory NumberArray.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'NumberArray', createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'numbers', $pb.PbFieldType.K3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  NumberArray clone() => NumberArray()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  NumberArray copyWith(void Function(NumberArray) updates) => super.copyWith((message) => updates(message as NumberArray)) as NumberArray;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NumberArray create() => NumberArray._();
  NumberArray createEmptyInstance() => create();
  static $pb.PbList<NumberArray> createRepeated() => $pb.PbList<NumberArray>();
  @$core.pragma('dart2js:noInline')
  static NumberArray getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NumberArray>(create);
  static NumberArray? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get numbers => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
