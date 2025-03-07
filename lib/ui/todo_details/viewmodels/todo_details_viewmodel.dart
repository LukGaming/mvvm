import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/commands/commands.dart';
import 'package:mvvm/utils/result/result.dart';

class TodoDetailsViewModel extends ChangeNotifier {
  final TodosRepository _todosRepository;

  TodoDetailsViewModel({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository {
    load = Command1(_load);
  }

  late final Command1<Todo, String> load;

  late Todo _todo;

  Todo get todo => _todo;

  Future<Result<Todo>> _load(String id) async {
    try {
      final result = await _todosRepository.getById(id);
      switch (result) {
        case Ok<Todo>():
          _todo = result.value;
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
