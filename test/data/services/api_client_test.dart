import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/data/services/api/models/todo/todo_api_model.dart';
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
      const CreateTodoApiModel todoToCreate =
          CreateTodoApiModel(name: "Todo created on TEST");

      final result = await apiClient.postTodo(todoToCreate);

      expect(result.asOk.value, isA<Todo>());
    });

    test("Should delete a Todo when deleteTodo()", () async {
      const CreateTodoApiModel todoToCreate =
          CreateTodoApiModel(name: "Todo created on TEST");

      final createdTodoResult = await apiClient.postTodo(todoToCreate);

      final result = await apiClient.deleteTodo(createdTodoResult.asOk.value);

      expect(result, isA<Result<void>>());
    });

    test("Should update a Todo when updateTodo()", () async {
      const CreateTodoApiModel todoToCreate = CreateTodoApiModel(
        name: "Todo created on TEST",
      );

      final createdTodoResult = await apiClient.postTodo(todoToCreate);

      final result = await apiClient.updateTodo(
        UpdateTodoApiModel(
          id: createdTodoResult.asOk.value.id!,
          name:
              "${createdTodoResult.asOk.value.name} updatedDate ${DateTime.now().toIso8601String()}",
        ),
      );

      expect(result, isA<Result<Todo>>());
    });

    test("Should getTodoById", () async {
      CreateTodoApiModel todoToCreate = CreateTodoApiModel(
        name: "Todo created on TEST ${DateTime.now()}",
      );

      final createdTodoResult = await apiClient.postTodo(todoToCreate);

      print("criando todo: ${createdTodoResult.asOk.value.toJson()}");

      final result =
          await apiClient.getTodoById(createdTodoResult.asOk.value.id);
      expect(result, isA<Result<Todo>>());

      expect(result.asOk.value.id, createdTodoResult.asOk.value.id);

      print(result.asOk.value.toJson());
    });
  });
}
