import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_remote.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late TodosRepositoryRemote todosRepository;
  late ApiClient apiClient;

  setUp(() {
    apiClient = MockApiClient();
    todosRepository = TodosRepositoryRemote(apiClient: apiClient);
  });

  test("Should get a Todo ById", () async {
    when(() => apiClient.getTodoById(any())).thenAnswer(
      (invocation) => Future.value(
        Result.ok(
          const Todo(
            id: "1",
            name: "Primeiro",
            description: "Descrição",
            done: false,
          ),
        ),
      ),
    );

    final result = await todosRepository.getById("1");

    expect(result, isA<Ok<Todo>>());

    expect(result.asOk.value.id, "1");
  });
}
