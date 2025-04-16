import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/utils/result/result.dart';

import '../../mock/todos.dart';

class TodosRepositoryMock extends Mock implements TodosRepository {}

void main() {
  late TodoUpdateUseCase todoUpdateUseCase;
  late TodosRepository todosRepository;

  setUp(() {
    todosRepository = TodosRepositoryMock();
    todoUpdateUseCase = TodoUpdateUseCase(
      todosRepository: todosRepository,
    );
  });

  group("TodoUpdateUseCase tests", () {
    test("updateTodo() returns Ok()", () async {
      when(
        () => todosRepository.updateTodo(updateTodoMockUseCase),
      ).thenAnswer(
        (_) => Future.value(Result.ok(updateTodoMockUseCase)),
      );

      final result = await todoUpdateUseCase.updateTodo(updateTodoMockUseCase);
      expect(result, isA<Ok<Todo>>());
    });

    test("updateTodo() returns Error()", () async {
      when(
        () => todosRepository.updateTodo(updateTodoMockUseCase),
      ).thenAnswer((invocation) => Future.value(
          Result.error(Exception("Ocorreu um erro ao atualizar todo."))));
      final result = await todosRepository.updateTodo(updateTodoMockUseCase);
      expect(result, isA<Error>());
    });
  });
}
