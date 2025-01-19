import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

void main() {
  late ApiClient apiClient;

  setUp(() {
    apiClient = ApiClient();
  });

  group("Should test [ApiClient]", () {
    test("Should return Result Ok when getTodos()", () async {
      final result = await apiClient.getTodos();

      expect(result.asOk.value, isA<List<Todo>>());
    });

    test("Should return a Todo when creating postTodo()", () async {
      final Todo todoToCreate = Todo(name: "Todo created on TEST");

      final result = await apiClient.postTodo(todoToCreate);

      expect(result.asOk.value, isA<Todo>());
    });

    test("Should delete a Todo when deleteTodo()", () async {
      final Todo todoToCreate = Todo(name: "Todo created on TEST");

      final createdTodoResult = await apiClient.postTodo(todoToCreate);

      final result = await apiClient.deleteTodo(createdTodoResult.asOk.value);

      expect(result, isA<Result<void>>());
    });
  });
}
