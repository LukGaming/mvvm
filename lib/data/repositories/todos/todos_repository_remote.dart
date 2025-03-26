import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/data/services/api/models/todo/todo_api_model.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

class TodosRepositoryRemote extends ChangeNotifier implements TodosRepository {
  final ApiClient _apiClient;

  TodosRepositoryRemote({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  List<Todo> get todos => _todos;

  List<Todo> _todos = [];

  @override
  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  }) async {
    try {
      final result = await _apiClient.postTodo(
        CreateTodoApiModel(
          name: name,
          description: description,
          done: done,
        ),
      );

      switch (result) {
        case Ok<Todo>():
          return Result.ok(result.value);
        default:
          return result;
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<void>> delete(Todo todo) async {
    try {
      final result = await _apiClient.deleteTodo(todo);
      switch (result) {
        case Ok<void>():
          return Result.ok(null);
        default:
          return result;
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<List<Todo>>> get() async {
    try {
      final result = await _apiClient.getTodos();

      switch (result) {
        case Ok<List<Todo>>():
          _todos = result.value;
          return Result.ok(result.value);
        default:
          return result;
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Result<Todo>> getById(String id) async {
    try {
      final result = await _apiClient.getTodoById(id);
      switch (result) {
        case Ok<Todo>():
          return Result.ok(result.value);
        default:
          return result;
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<Todo>> updateTodo(Todo todo) async {
    try {
      final result = await _apiClient.updateTodo(
        UpdateTodoApiModel(
          id: todo.id,
          name: todo.name,
          description: todo.description,
          done: todo.done,
        ),
      );

      switch (result) {
        case Ok<Todo>():
          final todoIndex = _todos.indexWhere((e) => e.id == todo.id);
          _todos[todoIndex] = result.value;
          return Result.ok(result.value);
        default:
          return result;
      }
    } on Exception catch (error) {
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }
}
