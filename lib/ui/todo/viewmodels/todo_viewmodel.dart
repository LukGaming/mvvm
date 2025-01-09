import 'package:flutter/material.dart';
import 'package:mvvm/core/commands/commands.dart';
import 'package:mvvm/core/result/result.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';

class TodoViewmodel extends ChangeNotifier {
  TodoViewmodel({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository {
    load = Commmand0(_load)..execute();
    addTodo = Command1(_addTodo);
    deleteTodo = Command1(_deleteTodo);
  }

  final TodosRepository _todosRepository;

  late Commmand0 load;

  late Command1<Todo, String> addTodo;

  late Command1<void, Todo> deleteTodo;

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

  Future<Result<Todo>> _addTodo(String name) async {
    final result = await _todosRepository.add(name);

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
}
