# 🧪 Estratégias de Teste

## 📋 Visão Geral

Este projeto implementa uma estratégia abrangente de testes seguindo a **pirâmide de testes**:

```
        🔺 E2E Tests (Few)
       🔺🔺 Integration Tests (Some)  
    🔺🔺🔺🔺 Unit Tests (Many)
```

## 🎯 Estrutura de Testes

### 📁 Organização

```
test/
├── 🏢 domain/                    # Testes de models e use cases
│   ├── models/
│   │   └── todo_test.dart
│   └── use_cases/
│       └── todo_update_use_case_test.dart
├── 📊 data/                      # Testes de repositories e services
│   ├── repositories/
│   │   └── todos_repository_test.dart
│   └── services/
│       └── api_client_test.dart
├── 🎨 ui/                        # Testes de ViewModels e Widgets
│   ├── todos/
│   │   └── viewmodels/
│   │       └── todo_viewmodel_test.dart
│   └── widgets/
│       └── todo_tile_test.dart
├── 🛠️ utils/                     # Testes de utilitários
│   ├── commands/
│   │   └── commands_test.dart
│   └── result/
│       └── result_test.dart
└── 🧪 mock/                      # Mocks e helpers de teste
    ├── mock_repositories.dart
    └── test_helpers.dart
```

## 🧪 Testes Unitários

### 📊 Testando Models

#### Exemplo: Todo Model Test

```dart
// test/domain/models/todo_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/todo.dart';

void main() {
  group('Todo Model Tests', () {
    const sampleTodo = Todo(
      id: "1",
      name: "Test Todo",
      description: "Test Description",
      done: false,
    );

    test('Should create Todo from JSON', () {
      // Arrange
      final json = {
        "id": "1",
        "name": "Test Todo",
        "description": "Test Description",
        "done": false,
      };

      // Act
      final todo = Todo.fromJson(json);

      // Assert
      expect(todo.id, equals("1"));
      expect(todo.name, equals("Test Todo"));
      expect(todo.description, equals("Test Description"));
      expect(todo.done, isFalse);
    });

    test('Should convert Todo to JSON', () {
      // Act
      final json = sampleTodo.toJson();

      // Assert
      expect(json['id'], equals("1"));
      expect(json['name'], equals("Test Todo"));
      expect(json['description'], equals("Test Description"));
      expect(json['done'], isFalse);
    });

    test('Should create copy with modified values', () {
      // Act
      final modifiedTodo = sampleTodo.copyWith(
        name: "Modified Todo",
        done: true,
      );

      // Assert
      expect(modifiedTodo.id, equals(sampleTodo.id));
      expect(modifiedTodo.name, equals("Modified Todo"));
      expect(modifiedTodo.description, equals(sampleTodo.description));
      expect(modifiedTodo.done, isTrue);
    });

    test('Should maintain immutability', () {
      // Act
      final modifiedTodo = sampleTodo.copyWith(name: "New Name");

      // Assert
      expect(sampleTodo.name, equals("Test Todo")); // Original unchanged
      expect(modifiedTodo.name, equals("New Name")); // New instance changed
    });

    test('Should handle empty values correctly', () {
      // Arrange
      const emptyTodo = Todo(
        id: "",
        name: "",
        description: "",
        done: false,
      );

      // Assert
      expect(emptyTodo.id, isEmpty);
      expect(emptyTodo.name, isEmpty);
      expect(emptyTodo.description, isEmpty);
    });
  });
}
```

### 🏢 Testando Use Cases

#### Exemplo: TodoUpdateUseCase Test

```dart
// test/domain/use_cases/todo_update_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/utils/result/result.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  late TodoUpdateUseCase useCase;
  late MockTodosRepository mockRepository;

  setUp(() {
    mockRepository = MockTodosRepository();
    useCase = TodoUpdateUseCase(todosRepository: mockRepository);
  });

  group('TodoUpdateUseCase Tests', () {
    const validTodo = Todo(
      id: "1",
      name: "Valid Todo",
      description: "Valid Description",
      done: false,
    );

    test('Should update todo successfully when valid', () async {
      // Arrange
      when(() => mockRepository.updateTodo(validTodo))
          .thenAnswer((_) async => Result.ok(validTodo));

      // Act
      final result = await useCase.updateTodo(validTodo);

      // Assert
      expect(result, isA<Ok<Todo>>());
      if (result is Ok<Todo>) {
        expect(result.value, equals(validTodo));
      }
      verify(() => mockRepository.updateTodo(validTodo)).called(1);
    });

    test('Should reject todo with empty name', () async {
      // Arrange
      const invalidTodo = Todo(
        id: "1",
        name: "",
        description: "Valid Description",
        done: false,
      );

      // Act
      final result = await useCase.updateTodo(invalidTodo);

      // Assert
      expect(result, isA<Error<Todo>>());
      if (result is Error<Todo>) {
        expect(
          result.error.toString(),
          contains("Nome do TODO não pode estar vazio"),
        );
      }
      verifyNever(() => mockRepository.updateTodo(any()));
    });

    test('Should reject todo with only whitespace in name', () async {
      // Arrange
      const invalidTodo = Todo(
        id: "1",
        name: "   ",
        description: "Valid Description",
        done: false,
      );

      // Act
      final result = await useCase.updateTodo(invalidTodo);

      // Assert
      expect(result, isA<Error<Todo>>());
      verifyNever(() => mockRepository.updateTodo(any()));
    });

    test('Should handle repository errors', () async {
      // Arrange
      final repositoryError = Exception("Database error");
      when(() => mockRepository.updateTodo(validTodo))
          .thenAnswer((_) async => Result.error(repositoryError));

      // Act
      final result = await useCase.updateTodo(validTodo);

      // Assert
      expect(result, isA<Error<Todo>>());
      if (result is Error<Todo>) {
        expect(result.error, equals(repositoryError));
      }
    });
  });
}
```

### 🎨 Testando ViewModels

#### Exemplo: TodoViewmodel Test

```dart
// test/ui/todos/viewmodels/todo_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_dev.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';

void main() {
  late TodoViewmodel todoViewmodel;
  late TodosRepository todosRepository;
  late TodoUpdateUseCase todoUpdateUseCase;

  setUp(() {
    todosRepository = TodosRepositoryDev();
    todoUpdateUseCase = TodoUpdateUseCase(todosRepository: todosRepository);
    todoViewmodel = TodoViewmodel(
      todosRepository: todosRepository,
      todoUpdateUseCase: todoUpdateUseCase,
    );
  });

  group("TodoViewModel Tests", () {
    test("Should initialize with empty todos list", () {
      expect(todoViewmodel.todos, isEmpty);
    });

    test("Should add todo successfully", () async {
      // Arrange
      expect(todoViewmodel.todos, isEmpty);

      // Act
      await todoViewmodel.addTodo.execute((
        "Novo todo",
        "Todo description",
        false,
      ));

      // Assert
      expect(todoViewmodel.todos, isNotEmpty);
      expect(todoViewmodel.todos.length, equals(1));
      expect(todoViewmodel.todos.first.name, equals("Novo todo"));
      expect(todoViewmodel.todos.first.description, equals("Todo description"));
      expect(todoViewmodel.todos.first.done, isFalse);
      expect(todoViewmodel.todos.first.id, isNotNull);
    });

    test("Should add multiple todos", () async {
      // Act
      await todoViewmodel.addTodo.execute((
        "Primeiro todo",
        "Primeira descrição",
        false,
      ));

      await todoViewmodel.addTodo.execute((
        "Segundo todo",
        "Segunda descrição",
        true,
      ));

      // Assert
      expect(todoViewmodel.todos.length, equals(2));
      expect(todoViewmodel.todos[0].name, equals("Primeiro todo"));
      expect(todoViewmodel.todos[1].name, equals("Segundo todo"));
      expect(todoViewmodel.todos[1].done, isTrue);
    });

    test("Should remove todo successfully", () async {
      // Arrange - Adicionar um todo primeiro
      await todoViewmodel.addTodo.execute((
        "Todo para remover",
        "Descrição",
        false,
      ));
      expect(todoViewmodel.todos, isNotEmpty);
      final todoToRemove = todoViewmodel.todos.first;

      // Act
      await todoViewmodel.deleteTodo.execute(todoToRemove);

      // Assert
      expect(todoViewmodel.todos, isEmpty);
    });

    test("Should update todo successfully", () async {
      // Arrange
      await todoViewmodel.addTodo.execute((
        "Todo original",
        "Descrição original",
        false,
      ));
      final originalTodo = todoViewmodel.todos.first;

      // Act
      final updatedTodo = originalTodo.copyWith(
        name: "Todo atualizado",
        done: true,
      );
      await todoViewmodel.updateTodo.execute(updatedTodo);

      // Assert
      expect(todoViewmodel.todos.length, equals(1));
      expect(todoViewmodel.todos.first.name, equals("Todo atualizado"));
      expect(todoViewmodel.todos.first.done, isTrue);
      expect(todoViewmodel.todos.first.id, equals(originalTodo.id));
    });

    test("Should handle command states correctly", () async {
      // Verificar estado inicial
      expect(todoViewmodel.addTodo.running, isFalse);
      expect(todoViewmodel.addTodo.completed, isFalse);
      expect(todoViewmodel.addTodo.error, isFalse);

      // Executar comando
      final future = todoViewmodel.addTodo.execute((
        "Test todo",
        "Test description",
        false,
      ));

      // Durante execução (pode ser rápido demais para capturar)
      // expect(todoViewmodel.addTodo.running, isTrue);

      // Aguardar conclusão
      await future;

      // Verificar estado final
      expect(todoViewmodel.addTodo.running, isFalse);
      expect(todoViewmodel.addTodo.completed, isTrue);
      expect(todoViewmodel.addTodo.error, isFalse);
    });

    test("Should notify listeners on state changes", () async {
      // Arrange
      bool wasNotified = false;
      todoViewmodel.addListener(() {
        wasNotified = true;
      });

      // Act
      await todoViewmodel.addTodo.execute((
        "Test todo",
        "Test description",
        false,
      ));

      // Assert
      expect(wasNotified, isTrue);
    });
  });
}
```

### 🛠️ Testando Utilitários

#### Exemplo: Commands Test

```dart
// test/utils/commands/commands_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/utils/commands/commands.dart';
import 'package:mvvm/utils/result/result.dart';

void main() {
  group('Command0 Tests', () {
    test('Should execute action successfully', () async {
      // Arrange
      const expectedValue = "Success";
      final command = Commmand0<String>(() async {
        return Result.ok(expectedValue);
      });

      // Act
      await command.execute();

      // Assert
      expect(command.running, isFalse);
      expect(command.completed, isTrue);
      expect(command.error, isFalse);
      expect(command.result, isA<Ok<String>>());
      if (command.result is Ok<String>) {
        expect((command.result as Ok<String>).value, equals(expectedValue));
      }
    });

    test('Should handle action errors', () async {
      // Arrange
      final expectedError = Exception("Test error");
      final command = Commmand0<String>(() async {
        return Result.error(expectedError);
      });

      // Act
      await command.execute();

      // Assert
      expect(command.running, isFalse);
      expect(command.completed, isFalse);
      expect(command.error, isTrue);
      expect(command.result, isA<Error<String>>());
    });

    test('Should prevent concurrent executions', () async {
      // Arrange
      int executionCount = 0;
      final command = Commmand0<String>(() async {
        executionCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return Result.ok("Success");
      });

      // Act
      final future1 = command.execute();
      final future2 = command.execute(); // Should be ignored

      await Future.wait([future1, future2]);

      // Assert
      expect(executionCount, equals(1)); // Only executed once
    });

    test('Should notify listeners on state changes', () async {
      // Arrange
      final command = Commmand0<String>(() async {
        await Future.delayed(const Duration(milliseconds: 10));
        return Result.ok("Success");
      });

      final stateChanges = <bool>[];
      command.addListener(() {
        stateChanges.add(command.running);
      });

      // Act
      await command.execute();

      // Assert
      expect(stateChanges, contains(true));  // Started running
      expect(stateChanges, contains(false)); // Stopped running
    });
  });

  group('Command1 Tests', () {
    test('Should execute with parameters', () async {
      // Arrange
      final command = Command1<int, int>((input) async {
        return Result.ok(input * 2);
      });

      // Act
      await command.execute(5);

      // Assert
      expect(command.completed, isTrue);
      if (command.result is Ok<int>) {
        expect((command.result as Ok<int>).value, equals(10));
      }
    });

    test('Should handle different parameter types', () async {
      // Arrange
      final command = Command1<String, (String, int)>((params) async {
        final (name, age) = params;
        return Result.ok("$name is $age years old");
      });

      // Act
      await command.execute(("John", 25));

      // Assert
      expect(command.completed, isTrue);
      if (command.result is Ok<String>) {
        expect(
          (command.result as Ok<String>).value,
          equals("John is 25 years old"),
        );
      }
    });
  });
}
```

#### Exemplo: Result Pattern Test

```dart
// test/utils/result/result_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/utils/result/result.dart';

void main() {
  group('Result Pattern Tests', () {
    test('Should create Ok result', () {
      // Arrange & Act
      final result = Result.ok("Success");

      // Assert
      expect(result, isA<Ok<String>>());
      if (result is Ok<String>) {
        expect(result.value, equals("Success"));
      }
    });

    test('Should create Error result', () {
      // Arrange
      final error = Exception("Test error");

      // Act
      final result = Result.error(error);

      // Assert
      expect(result, isA<Error>());
      if (result is Error) {
        expect(result.error, equals(error));
      }
    });

    test('Should work with pattern matching', () {
      // Arrange
      final okResult = Result.ok(42);
      final errorResult = Result.error(Exception("Error"));

      // Act & Assert
      switch (okResult) {
        case Ok<int>():
          expect(okResult.value, equals(42));
          break;
        case Error<int>():
          fail("Should not be an error");
      }

      switch (errorResult) {
        case Ok<int>():
          fail("Should not be ok");
        case Error<int>():
          expect(errorResult.error, isA<Exception>());
          break;
      }
    });

    test('Should work with different types', () {
      // Test with custom object
      final user = User(id: "1", name: "John");
      final userResult = Result.ok(user);

      expect(userResult, isA<Ok<User>>());
      if (userResult is Ok<User>) {
        expect(userResult.value.name, equals("John"));
      }

      // Test with List
      final listResult = Result.ok([1, 2, 3]);
      expect(listResult, isA<Ok<List<int>>>());

      // Test with void
      final voidResult = Result.ok(null);
      expect(voidResult, isA<Ok>());
    });
  });
}

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}
```

## 🧪 Testes de Widget

### 🎨 Testando Widgets

```dart
// test/ui/widgets/todo_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_tile.dart';

class MockTodoViewmodel extends Mock implements TodoViewmodel {}

void main() {
  late MockTodoViewmodel mockViewmodel;

  setUp(() {
    mockViewmodel = MockTodoViewmodel();
  });

  group('TodoTile Widget Tests', () {
    const testTodo = Todo(
      id: "1",
      name: "Test Todo",
      description: "Test Description",
      done: false,
    );

    testWidgets('Should display todo information', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoTile(
              todo: testTodo,
              todoViewmodel: mockViewmodel,
              onDeleteTodo: (todo) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text("Test Todo"), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('Should show checked checkbox when todo is done', (tester) async {
      // Arrange
      const doneTodo = Todo(
        id: "1",
        name: "Done Todo",
        description: "Completed",
        done: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoTile(
              todo: doneTodo,
              todoViewmodel: mockViewmodel,
              onDeleteTodo: (todo) {},
            ),
          ),
        ),
      );

      // Act
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

      // Assert
      expect(checkbox.value, isTrue);
    });

    testWidgets('Should call onDeleteTodo when delete button pressed', (tester) async {
      // Arrange
      bool deleteCalled = false;
      Todo? deletedTodo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoTile(
              todo: testTodo,
              todoViewmodel: mockViewmodel,
              onDeleteTodo: (todo) {
                deleteCalled = true;
                deletedTodo = todo;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Assert
      expect(deleteCalled, isTrue);
      expect(deletedTodo, equals(testTodo));
    });

    testWidgets('Should update todo when checkbox is toggled', (tester) async {
      // Arrange
      when(() => mockViewmodel.updateTodo).thenReturn(
        Command1((todo) async => Result.ok(todo)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoTile(
              todo: testTodo,
              todoViewmodel: mockViewmodel,
              onDeleteTodo: (todo) {},
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Assert
      verify(() => mockViewmodel.updateTodo.execute(any())).called(1);
    });
  });
}
```

## 🧪 Testes de Integração

### 🔗 Testando Fluxos Completos

```dart
// test/integration/todo_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_dev.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('Todo Flow Integration Tests', () {
    testWidgets('Should complete full todo lifecycle', (tester) async {
      // Arrange
      final repository = TodosRepositoryDev();
      final useCase = TodoUpdateUseCase(todosRepository: repository);
      final viewmodel = TodoViewmodel(
        todosRepository: repository,
        todoUpdateUseCase: useCase,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: repository),
              Provider.value(value: useCase),
            ],
            child: TodoScreen(todoViewmodel: viewmodel),
          ),
        ),
      );

      // Aguardar carregamento inicial
      await tester.pumpAndSettle();

      // Assert - Tela inicial deve estar vazia
      expect(find.text("Nenhuma tarefa por enquanto..."), findsOneWidget);

      // Act - Adicionar um todo
      await tester.enterText(find.byType(TextField).first, "Novo Todo");
      await tester.enterText(find.byType(TextField).last, "Descrição do novo todo");
      await tester.tap(find.text("Adicionar"));
      await tester.pumpAndSettle();

      // Assert - Todo deve aparecer na lista
      expect(find.text("Novo Todo"), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);

      // Act - Marcar como concluído
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Assert - Checkbox deve estar marcado
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);

      // Act - Deletar o todo
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Assert - Lista deve ficar vazia novamente
      expect(find.text("Nenhuma tarefa por enquanto..."), findsOneWidget);
    });
  });
}
```

## 🧪 Mocks e Test Helpers

### 🎭 Criando Mocks Reutilizáveis

```dart
// test/mock/mock_repositories.dart
import 'package:mocktail/mocktail.dart';
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/utils/result/result.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodosRepository extends Fake implements TodosRepository {
  final List<Todo> _todos = [];

  @override
  List<Todo> get todos => List.unmodifiable(_todos);

  @override
  Future<Result<List<Todo>>> get() async {
    return Result.ok(_todos);
  }

  @override
  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  }) async {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      done: done,
    );
    
    _todos.add(todo);
    notifyListeners();
    
    return Result.ok(todo);
  }

  @override
  Future<Result<void>> delete(Todo todo) async {
    _todos.removeWhere((t) => t.id == todo.id);
    notifyListeners();
    return Result.ok(null);
  }

  @override
  Future<Result<Todo>> getById(String id) async {
    try {
      final todo = _todos.firstWhere((t) => t.id == id);
      return Result.ok(todo);
    } catch (e) {
      return Result.error(Exception("Todo não encontrado"));
    }
  }

  @override
  Future<Result<Todo>> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
      notifyListeners();
      return Result.ok(todo);
    }
    return Result.error(Exception("Todo não encontrado"));
  }
}
```

### 🛠️ Test Helpers

```dart
// test/mock/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/domain/models/todo.dart';

class TestHelpers {
  static const sampleTodo = Todo(
    id: "test-1",
    name: "Sample Todo",
    description: "Sample Description",
    done: false,
  );

  static List<Todo> createSampleTodos(int count) {
    return List.generate(count, (index) => Todo(
      id: "test-${index + 1}",
      name: "Todo ${index + 1}",
      description: "Description ${index + 1}",
      done: index % 2 == 0, // Alternar entre done/not done
    ));
  }

  static Widget wrapWithMaterialApp(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  static Future<void> pumpWithSettle(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }
}

// Extensions para facilitar testes
extension WidgetTesterExtensions on WidgetTester {
  Future<void> pumpMaterialApp(Widget child) async {
    await pumpWidget(TestHelpers.wrapWithMaterialApp(child));
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
```

## 🎯 Executando Testes

### 🏃‍♂️ Comandos Básicos

```bash
# Executar todos os testes
flutter test

# Executar testes específicos
flutter test test/ui/todos/viewmodels/todo_viewmodel_test.dart

# Executar testes de uma pasta
flutter test test/domain/

# Executar com verbosidade
flutter test --verbose

# Executar com coverage
flutter test --coverage

# Executar apenas testes que contêm determinado nome
flutter test --plain-name "Should add todo"
```

### 📊 Coverage Report

```bash
# Gerar coverage
flutter test --coverage

# Visualizar coverage (requer lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 🔄 Watch Mode

```bash
# Executar testes automaticamente quando arquivos mudarem
flutter test --watch
```

## ✅ Melhores Práticas

### 🎯 Estrutura dos Testes

```dart
void main() {
  group('Feature Tests', () {
    late MyClass myClass;
    late MockDependency mockDependency;

    setUp(() {
      // Configuração para cada teste
      mockDependency = MockDependency();
      myClass = MyClass(dependency: mockDependency);
    });

    tearDown(() {
      // Limpeza após cada teste (se necessário)
    });

    test('Should do something when condition is met', () async {
      // Arrange - Configurar dados e mocks
      when(() => mockDependency.method()).thenReturn(expectedValue);

      // Act - Executar a ação sendo testada
      final result = await myClass.doSomething();

      // Assert - Verificar o resultado
      expect(result, equals(expectedValue));
      verify(() => mockDependency.method()).called(1);
    });
  });
}
```

### 🧪 Naming Conventions

```dart
// ✅ Bom: Descritivo e específico
test('Should add todo to list when valid data is provided', () {});
test('Should return error when todo name is empty', () {});
test('Should update todo status when checkbox is tapped', () {});

// ❌ Ruim: Vago e pouco descritivo
test('Test add todo', () {});
test('Error case', () {});
test('Update test', () {});
```

### 🎭 Usando Mocks Efetivamente

```dart
// ✅ Configurar comportamento específico
when(() => mockRepository.getTodos())
    .thenAnswer((_) async => Result.ok([sampleTodo]));

// ✅ Verificar interações
verify(() => mockRepository.add(
  name: "New Todo",
  description: "Description",
  done: false,
)).called(1);

// ✅ Verificar que algo NÃO foi chamado
verifyNever(() => mockRepository.delete(any()));

// ✅ Usar argumentos capturados
final captured = verify(() => mockRepository.updateTodo(captureAny())).captured;
expect(captured.first, isA<Todo>());
```

### 📊 Cobertura de Código

**Objetivos de cobertura:**
- ✅ **Models**: 100% (são simples, devem ser totalmente cobertos)
- ✅ **Use Cases**: 95%+ (lógica crítica de negócio)
- ✅ **ViewModels**: 90%+ (lógica de apresentação)
- ✅ **Repositories**: 85%+ (incluir casos de erro)
- ✅ **Widgets**: 70%+ (focar nos casos principais)

### 🚀 Performance dos Testes

```dart
// ✅ Usar setUp para inicialização comum
setUp(() {
  // Configuração reutilizável
});

// ✅ Evitar delays desnecessários em testes unitários
// ❌ Ruim
await Future.delayed(Duration(seconds: 1));

// ✅ Bom - usar pump/pumpAndSettle para widgets
await tester.pumpAndSettle();

// ✅ Usar timeouts apropriados
test('Should complete quickly', () async {
  // teste
}, timeout: Timeout(Duration(seconds: 5)));
```

---

**Anterior:** [Guia de Desenvolvimento](./05-guia-desenvolvimento.md) | **Próximo:** [Deployment](./07-deployment.md)
