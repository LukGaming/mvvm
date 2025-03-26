import 'package:flutter/material.dart';
import 'package:mvvm/utils/result/result.dart';
import 'package:mvvm/domain/models/todo.dart';

abstract class TodosRepository extends ChangeNotifier {
  List<Todo> get todos;

  Future<Result<List<Todo>>> get();

  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  });

  Future<Result<void>> delete(Todo todo);

  Future<Result<Todo>> getById(String id);

  Future<Result<Todo>> updateTodo(Todo todo);
}
