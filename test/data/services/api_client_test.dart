import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/data/services/api/models/todo/todo_api_model.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

import '../../mock/http_client_mock.dart';
import '../../mock/todos.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late ApiClient apiClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiClient = ApiClient(clientHttpFactory: () => mockHttpClient);
  });

  group("Should test [ApiClient]", () {
    test("Should return Result Ok when getTodos()", () async {
      mockHttpClient.mockGet("/todos", mockGetTodos);

      final result = await apiClient.getTodos();

      expect(result.asOk.value, isA<List<Todo>>());
    });

    test("Should return a Todo when creating postTodo()", () async {
      mockHttpClient.mockPost("/todos", mockTodoPostResponse);

      final result = await apiClient.postTodo(mockTodoPost);

      expect(result.asOk.value, isA<Todo>());
    });

    test("Should delete a Todo when deleteTodo()", () async {
      const Todo todo = Todo(
        id: "1",
        name: "Todo created on TEST",
        description: "Test description",
        done: false,
      );

      mockHttpClient.mockDelete("/todos/1", todo);

      final result = await apiClient.deleteTodo(todo);

      expect(result, isA<Result<void>>());
    });

    test("Should update a Todo when updateTodo()", () async {
      final updatedDate = DateTime.now().toIso8601String();

      final updatedTodo = Todo(
        id: "1",
        name: "updatedDate $updatedDate",
        description: "Test description",
        done: true,
      );

      final todoToUpdate = UpdateTodoApiModel(
        id: "1",
        name: "updatedDate $updatedDate",
        description: "Test description",
        done: true,
      );

      mockHttpClient.mockPut("/todos/1", updatedTodo);

      final result = await apiClient.updateTodo(todoToUpdate);

      expect(result, isA<Result<Todo>>());

      expect(result.asOk.value.done, true);
    });

    test("Should getTodoById", () async {
      mockHttpClient.mockGet("/todos/1", mockGetById);

      final result = await apiClient.getTodoById("1");
      expect(result, isA<Result<Todo>>());

      final todo = result.asOk.value;

      expect(todo.id, "1");
    });
  });
}
