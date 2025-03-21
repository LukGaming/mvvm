import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

class TodoUpdateUseCase {
  final TodosRepository _todosRepository;

  TodoUpdateUseCase({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository;

  Future<Result<Todo>> updateTodo(Todo todo) async {
    try {
      final result = await _todosRepository.updateTodo(todo);

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
}
