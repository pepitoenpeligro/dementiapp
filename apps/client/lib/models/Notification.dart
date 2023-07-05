/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:amplify_core/amplify_core.dart';
import 'package:flutter/foundation.dart';

/** This is an auto generated class representing the Notification type in your schema. */
@immutable
class NotificationModel extends Model {
  static const classType = const _NotificationModelType();
  final String id;
  final String? _title;
  final String? _message;
  final String? _timestamp;
  final String? _userId;
  final TemporalDateTime? _createdAt;
  final TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @Deprecated(
      '[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;

  NotificationModelIdentifier get modelIdentifier {
    return NotificationModelIdentifier(id: id);
  }

  String? get title {
    return _title;
  }

  String? get message {
    return _message;
  }

  String? get timestamp {
    return _timestamp;
  }

  String? get userId {
    return _userId;
  }

  TemporalDateTime? get createdAt {
    return _createdAt;
  }

  TemporalDateTime? get updatedAt {
    return _updatedAt;
  }

  const NotificationModel._internal(
      {required this.id,
      title,
      message,
      timestamp,
      userId,
      createdAt,
      updatedAt})
      : _title = title,
        _message = message,
        _timestamp = timestamp,
        _userId = userId,
        _createdAt = createdAt,
        _updatedAt = updatedAt;

  factory NotificationModel(
      {String? id,
      String? title,
      String? message,
      String? timestamp,
      String? userId}) {
    return NotificationModel._internal(
        id: id == null ? UUID.getUUID() : id,
        title: title,
        message: message,
        timestamp: timestamp,
        userId: userId);
  }

  bool equals(Object other) {
    return this == other;
  }

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationModel &&
        id == other.id &&
        _title == other._title &&
        _message == other._message &&
        _timestamp == other._timestamp &&
        _userId == other._userId;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();

    buffer.write("Notification {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("title=" + "$_title" + ", ");
    buffer.write("message=" + "$_message" + ", ");
    buffer.write("timestamp=" + "$_timestamp" + ", ");
    buffer.write("userId=" + "$_userId" + ", ");
    buffer.write("createdAt=" +
        (_createdAt != null ? _createdAt!.format() : "null") +
        ", ");
    buffer.write(
        "updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");

    return buffer.toString();
  }

  NotificationModel copyWith(
      {String? title, String? message, String? timestamp, String? userId}) {
    return NotificationModel._internal(
        id: id,
        title: title ?? this.title,
        message: message ?? this.message,
        timestamp: timestamp ?? this.timestamp,
        userId: userId ?? this.userId);
  }

  NotificationModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        _title = json['title'],
        _message = json['message'],
        _timestamp = json['timestamp'],
        _userId = json['userId'],
        _createdAt = json['createdAt'] != null
            ? TemporalDateTime.fromString(json['createdAt'])
            : null,
        _updatedAt = json['updatedAt'] != null
            ? TemporalDateTime.fromString(json['updatedAt'])
            : null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': _title,
        'message': _message,
        'timestamp': _timestamp,
        'userId': _userId,
        'createdAt': _createdAt?.format(),
        'updatedAt': _updatedAt?.format()
      };

  Map<String, Object?> toMap() => {
        'id': id,
        'title': _title,
        'message': _message,
        'timestamp': _timestamp,
        'userId': _userId,
        'createdAt': _createdAt,
        'updatedAt': _updatedAt
      };

  static final QueryModelIdentifier<NotificationModelIdentifier>
      MODEL_IDENTIFIER = QueryModelIdentifier<NotificationModelIdentifier>();
  static final QueryField ID = QueryField(fieldName: "id");
  static final QueryField TITLE = QueryField(fieldName: "title");
  static final QueryField MESSAGE = QueryField(fieldName: "message");
  static final QueryField TIMESTAMP = QueryField(fieldName: "timestamp");
  static final QueryField USERID = QueryField(fieldName: "userId");
  static var schema =
      Model.defineSchema(define: (ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "Notification";
    modelSchemaDefinition.pluralName = "Notifications";

    modelSchemaDefinition.authRules = [
      AuthRule(authStrategy: AuthStrategy.PUBLIC, operations: [
        ModelOperation.CREATE,
        ModelOperation.UPDATE,
        ModelOperation.DELETE,
        ModelOperation.READ
      ])
    ];

    modelSchemaDefinition.addField(ModelFieldDefinition.id());

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: NotificationModel.TITLE,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: NotificationModel.MESSAGE,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: NotificationModel.TIMESTAMP,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.field(
        key: NotificationModel.USERID,
        isRequired: false,
        ofType: ModelFieldType(ModelFieldTypeEnum.string)));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'createdAt',
        isRequired: false,
        isReadOnly: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)));

    modelSchemaDefinition.addField(ModelFieldDefinition.nonQueryField(
        fieldName: 'updatedAt',
        isRequired: false,
        isReadOnly: true,
        ofType: ModelFieldType(ModelFieldTypeEnum.dateTime)));
  });
}

class _NotificationModelType extends ModelType<NotificationModel> {
  const _NotificationModelType();

  @override
  NotificationModel fromJson(Map<String, dynamic> jsonData) {
    return NotificationModel.fromJson(jsonData);
  }
}

/**
 * This is an auto generated class representing the model identifier
 * of [Notification] in your schema.
 */
@immutable
class NotificationModelIdentifier
    implements ModelIdentifier<NotificationModel> {
  final String id;

  /** Create an instance of NotificationModelIdentifier using [id] the primary key. */
  const NotificationModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
      .entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'NotificationModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is NotificationModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
