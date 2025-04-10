import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_remote.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/data/services/api/models/todo/todo_api_model.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

import '../../../mock/todos.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late TodosRepositoryRemote todosRepository;
  late ApiClient apiClient;

  setUp(() {
    apiClient = MockApiClient();
    todosRepository = TodosRepositoryRemote(apiClient: apiClient);
  });

  group("TodosRepositoryRemote test", () {
    test("getById()", () async {
      when(() => apiClient.getTodoById(any())).thenAnswer(
        (invocation) => Future.value(
          Result.ok(mockGetById),
        ),
      );

      final result = await todosRepository.getById("1");

      expect(result, isA<Ok<Todo>>());

      final todo = result.asOk.value;
      expect(todo.id, "1");
      expect(todo.name, "Primeiro");
      expect(todo.description, "Descrição");
      expect(todo.done, false);

      final secondCallResult = await todosRepository.getById("1");
      expect(secondCallResult, isA<Ok<Todo>>());
      final secondCallTodo = secondCallResult.asOk.value;
      expect(secondCallTodo.id, "1");
      expect(secondCallTodo.name, "Primeiro");
      expect(secondCallTodo.description, "Descrição");
      expect(secondCallTodo.done, false);

      verify(() => apiClient.getTodoById(any())).called(1);
    });
  });

  test("add()", () async {
    when(() => apiClient.postTodo(
          createTodoMock,
        )).thenAnswer((invocation) => Future.value(Result.ok(addTodoMock)));

    bool wasNotified = false;

    todosRepository.addListener(() {
      wasNotified = true;
    });

    final result = await todosRepository.add(
      name: "Nome",
      description: "Descrição",
      done: false,
    );

    expect(result, isA<Ok<Todo>>());

    final createdTodo = result.asOk.value;

    expect(todosRepository.todos.contains(addTodoMock), isTrue);

    expect(createdTodo.id, "1");
    expect(createdTodo.name, "Nome");
    expect(createdTodo.description, "Descrição");
    expect(createdTodo.done, false);

    expect(wasNotified, true);
  });

  test("delete()", () async {
    when(() => apiClient.deleteTodo(addTodoMock)).thenAnswer(
      (invocation) => Future.value(Result.ok(null)),
    );

    when(
      () => apiClient.getTodos(),
    ).thenAnswer(
      (invocation) => Future.value(
        Result.ok([addTodoMock]),
      ),
    );

    final result = await todosRepository.get();

    expect(result, isA<Ok<List<Todo>>>());
    expect(todosRepository.todos.contains(addTodoMock), isTrue);

    bool wasNotified = false;

    todosRepository.addListener(() {
      wasNotified = true;
    });

    final deleteResult =
        await todosRepository.delete(todosRepository.todos.first);

    expect(deleteResult, isA<Ok<void>>());

    expect(todosRepository.todos.contains(addTodoMock), isFalse);

    expect(wasNotified, true);
  });
}
