import 'package:flutter/material.dart';
import 'package:mvvm/utils/commands/commands.dart';
import 'package:mvvm/utils/result/result.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';

class TodoViewmodel extends ChangeNotifier {
  TodoViewmodel({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository {
    load = Commmand0(_load)..execute();
    addTodo = Command1(_addTodo);
    deleteTodo = Command1(_deleteTodo);
    updateTodo = Command1(_updateTodo);
  }

  final TodosRepository _todosRepository;

  late Commmand0 load;

  late Command1<Todo, (String, String, bool)> addTodo;

  late Command1<void, Todo> deleteTodo;

  late Command1<Todo, Todo> updateTodo;

  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<Result> _load() async {
    final result = await _todosRepository.get();

    switch (result) {
      case Ok<List<Todo>>():
        _todos = result.value;
        notifyListeners();
        break;
      case Error():
        //TODO: implement LOGGING
        break;
    }

    return result;
  }

  Future<Result<Todo>> _addTodo((String, String, bool) todo) async {
    final (name, description, done) = todo;

    final result = await _todosRepository.add(
      name: name,
      description: description,
      done: done,
    );

    switch (result) {
      case Ok<Todo>():
        _todos.add(result.value);
        notifyListeners();
        break;
      case Error():
      //TODO: implement LOGGING
      default:
    }

    return result;
  }

  Future<Result<void>> _deleteTodo(Todo todo) async {
    final result = await _todosRepository.delete(todo);

    switch (result) {
      case Ok<void>():
        _todos.remove(todo);
        notifyListeners();
        break;
      case Error():
      //TODO: implement LOGGING
      default:
    }
    return result;
  }

  Future<Result<Todo>> _updateTodo(Todo todo) async {
    final result = await _todosRepository.updateTodo(todo);

    switch (result) {
      case Ok<Todo>():
        final todoIndex = _todos.indexWhere((e) => e.id == todo.id);
        _todos[todoIndex] = result.value;
        notifyListeners();
        return Result.ok(result.value);
      default:
        return result;
    }
  }
}
