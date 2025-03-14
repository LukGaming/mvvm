// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateTodoApiModelImpl _$$CreateTodoApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateTodoApiModelImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      done: json['done'] as bool,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CreateTodoApiModelImplToJson(
        _$CreateTodoApiModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'done': instance.done,
      'runtimeType': instance.$type,
    };

_$UpdateTodoApiModelImpl _$$UpdateTodoApiModelImplFromJson(
        Map<String, dynamic> json) =>
    _$UpdateTodoApiModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      done: json['done'] as bool,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$UpdateTodoApiModelImplToJson(
        _$UpdateTodoApiModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'done': instance.done,
      'runtimeType': instance.$type,
    };
