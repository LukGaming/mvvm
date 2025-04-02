import 'package:flutter/material.dart';
import 'package:mvvm/utils/result/result.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';

class TodosRepositoryDev extends ChangeNotifier implements TodosRepository {
  final List<Todo> _todos = [];

  @override
  List<Todo> get todos => _todos;

  @override
  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  }) async {
    try {
      final lastTodoIndex = _todos.length;

      final Todo createdTodo = Todo(
        id: (lastTodoIndex + 1).toString(),
        name: name,
        description: description,
        done: done,
      );

      return Result.ok(createdTodo);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> delete(Todo todo) async {
    if (_todos.contains(todo)) {
      _todos.remove(todo);
    }
    return Result.ok(null);
  }

  @override
  Future<Result<List<Todo>>> get() async {
    return Result.ok(_todos);
  }

  @override
  Future<Result<Todo>> getById(String id) async {
    return Result.ok(_todos.where((e) => e.id == id).first);
  }

  @override
  Future<Result<Todo>> updateTodo(
    Todo todo,
  ) async {
    try {
      final todoIndex = _todos.indexWhere((e) => e.id == todo.id);

      _todos[todoIndex] = todo;

      return Result.ok(todo);
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }
}
