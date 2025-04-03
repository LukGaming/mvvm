import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/utils/commands/commands.dart';
import 'package:mvvm/utils/result/result.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';

class TodoViewmodel extends ChangeNotifier {
  TodoViewmodel({
    required TodosRepository todosRepository,
    required TodoUpdateUseCase todoUpdateUseCase,
  })  : _todosRepository = todosRepository,
        _todoUpdateUseCase = todoUpdateUseCase {
    load = Commmand0(_load)..execute();
    addTodo = Command1(_addTodo);
    deleteTodo = Command1(_deleteTodo);
    updateTodo = Command1((todo) => _todoUpdateUseCase.updateTodo(todo));
    _todosRepository.addListener(() {
      _todos = _todosRepository.todos;
      notifyListeners();
    });
  }

  final TodosRepository _todosRepository;

  final TodoUpdateUseCase _todoUpdateUseCase;

  late Commmand0 load;

  late Command1<Todo, (String, String, bool)> addTodo;

  late Command1<void, Todo> deleteTodo;

  late Command1<Todo, Todo> updateTodo;

  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  final _log = Logger("TodoViewModel");

  Future<Result> _load() async {
    try {
      final result = await _todosRepository.get();

      switch (result) {
        case Ok<List<Todo>>():
          _todos = result.value;

          _log.fine("Todos carregados");
          break;
        case Error():
          _log.warning("Falha ao carregar todos", result.error);
          break;
      }

      return result;
    } on Exception catch (error, stackStack) {
      _log.warning("Falha ao carregar todos", error, stackStack);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<Todo>> _addTodo((String, String, bool) todo) async {
    final (name, description, done) = todo;

    try {
      final result = await _todosRepository.add(
        name: name,
        description: description,
        done: done,
      );

      switch (result) {
        case Ok<Todo>():
          _todos.add(result.value);
          _log.fine("Todo criado");
          break;
        case Error():
          _log.warning("Erro ao criar todo");
        default:
      }

      return result;
    } on Exception catch (error, stackStack) {
      _log.warning("Erro ao criar todo", error, stackStack);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _deleteTodo(Todo todo) async {
    try {
      final result = await _todosRepository.delete(todo);

      switch (result) {
        case Ok<void>():
          _todos.remove(todo);
          _log.fine("Todo Removido");
          break;
        case Error():
          _log.warning("falha ao remover Todo");
        default:
      }
      return result;
    } on Exception catch (error, stackStack) {
      _log.warning("Falha ao deletar todo", error, stackStack);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }
}
