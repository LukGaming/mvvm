import 'package:logging/logging.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

class TodoUpdateUseCase {
  final TodosRepository _todosRepository;
  final _log = Logger("TodoUpdateUseCase");

  TodoUpdateUseCase({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository;

  Future<Result<Todo>> updateTodo(Todo todo) async {
    try {
      final result = await _todosRepository.updateTodo(todo);

      switch (result) {
        case Ok<Todo>():
          _log.fine("Todo alterado");
          return Result.ok(result.value);

        default:
          return result;
      }
    } on Exception catch (error, stackTrace) {
      _log.warning("Falha ao alterar todo", error, stackTrace);
      return Result.error(error);
    }
  }
}
