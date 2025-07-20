# 🎨 Padrões de Código

## 📋 Visão Geral dos Padrões

Este projeto implementa diversos padrões de design para garantir:
- ✅ **Código limpo e maintível**
- ✅ **Separação de responsabilidades**
- ✅ **Testabilidade**
- ✅ **Reutilização**
- ✅ **Tratamento robusto de erros**

## 🎯 Command Pattern

### 📖 Conceito

O **Command Pattern** encapsula uma ação como um objeto, permitindo:
- Parametrizar objetos com diferentes ações
- Enfileirar, registrar ou desfazer operações
- Gerenciar estado da execução (loading, success, error)

### 🏗️ Implementação

#### Base Class: Command

```dart
abstract class Command<Output> extends ChangeNotifier {
  // Estado da execução
  bool _running = false;
  bool get running => _running;

  // Resultado da execução
  Result<Output>? _result;
  Result<Output>? get result => _result;

  // Estados derivados
  bool get completed => _result is Ok;
  bool get error => _result is Error;

  // Execução protegida
  Future<void> _execute(CommandAction0<Output> action) async {
    if (_running) return; // Evita execução simultânea

    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
```

#### Command0: Sem Parâmetros

```dart
typedef CommandAction0<Output> = Future<Result<Output>> Function();

class Commmand0<Output> extends Command<Output> {
  final CommandAction0<Output> action;
  
  Commmand0(this.action);

  Future<void> execute() async {
    await _execute(() => action());
  }
}
```

#### Command1: Com Parâmetros

```dart
typedef CommandAction1<Output, Input> = Future<Result<Output>> Function(Input);

class Command1<Output, Input> extends Command<Output> {
  final CommandAction1<Output, Input> action;

  Command1(this.action);

  Future<void> execute(Input params) async {
    await _execute(() => action(params));
  }
}
```

### 🚀 Uso Prático

#### No ViewModel

```dart
class TodoViewmodel extends ChangeNotifier {
  TodoViewmodel({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository {
    // Comando para carregar dados (sem parâmetros)
    load = Commmand0(_load)..execute();
    
    // Comando para adicionar TODO (com parâmetros)
    addTodo = Command1(_addTodo);
    
    // Comando para deletar TODO
    deleteTodo = Command1(_deleteTodo);
  }

  late final Commmand0<List<Todo>> load;
  late final Command1<Todo, (String, String, bool)> addTodo;
  late final Command1<void, Todo> deleteTodo;

  // Implementação das ações
  Future<Result<List<Todo>>> _load() async {
    try {
      final result = await _todosRepository.get();
      
      switch (result) {
        case Ok<List<Todo>>():
          _todos = result.value;
          break;
        case Error():
          _log.warning("Erro ao carregar", result.error);
          break;
      }
      
      return result;
    } catch (e) {
      return Result.error(e as Exception);
    }
  }

  Future<Result<Todo>> _addTodo((String, String, bool) params) async {
    final (name, description, done) = params;
    
    try {
      final result = await _todosRepository.add(
        name: name,
        description: description,
        done: done,
      );

      if (result is Ok<Todo>) {
        _todos.add(result.value);
        notifyListeners();
      }

      return result;
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
}
```

#### Na View

```dart
class AddTodoWidget extends StatefulWidget {
  final TodoViewmodel todoViewmodel;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formulário
        TextField(controller: nameController),
        TextField(controller: descriptionController),
        
        // Botão com estado reativo
        ListenableBuilder(
          listenable: widget.todoViewmodel.addTodo,
          builder: (context, child) {
            final command = widget.todoViewmodel.addTodo;
            
            return ElevatedButton(
              onPressed: command.running ? null : _onAddTodo,
              child: command.running 
                ? const CircularProgressIndicator()
                : const Text("Adicionar"),
            );
          },
        ),
      ],
    );
  }

  void _onAddTodo() {
    widget.todoViewmodel.addTodo.execute((
      nameController.text,
      descriptionController.text,
      false,
    ));
  }
}
```

## 📊 Result Pattern

### 📖 Conceito

O **Result Pattern** representa o resultado de uma operação que pode falhar, sem usar exceptions para controle de fluxo:

- ✅ **Sucesso**: `Result.ok(value)`
- ❌ **Erro**: `Result.error(exception)`

### 🏗️ Implementação

```dart
abstract class Result<T> {
  const Result();

  factory Result.ok(T value) = Ok._;
  factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  final T value;
  Ok._(this.value);
}

final class Error<T> extends Result<T> {
  final Exception error;
  Error._(this.error);
}
```

### 🔧 Extensions Úteis

```dart
extension ResultExtension on Object {
  Result ok() => Result.ok(this);
}

extension ResultException on Exception {
  Result error() => Result.error(this);
}
```

### 🚀 Uso Prático

#### Retornando Result

```dart
Future<Result<List<Todo>>> getTodos() async {
  try {
    final response = await httpClient.get('/todos');
    
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      final todos = json.map((e) => Todo.fromJson(e)).toList();
      return Result.ok(todos);
    } else {
      return Result.error(
        Exception("Falha na requisição: ${response.statusCode}")
      );
    }
  } catch (e) {
    return Result.error(e as Exception);
  }
}
```

#### Consumindo Result

```dart
// Usando pattern matching (switch expression)
final result = await repository.getTodos();

switch (result) {
  case Ok<List<Todo>>():
    _todos = result.value;
    _showSuccess("Todos carregados com sucesso");
    break;
    
  case Error<List<Todo>>():
    _showError("Erro: ${result.error.toString()}");
    break;
}
```

#### Result com Transformações

```dart
// Mapeando resultado
Result<List<String>> mapTodoNames(Result<List<Todo>> todosResult) {
  switch (todosResult) {
    case Ok<List<Todo>>():
      final names = todosResult.value.map((todo) => todo.name).toList();
      return Result.ok(names);
      
    case Error<List<Todo>>():
      return Result.error(todosResult.error);
  }
}

// Usando em cadeia
final todosResult = await repository.getTodos();
final namesResult = mapTodoNames(todosResult);
```

## 🏛️ Repository Pattern

### 📖 Conceito

O **Repository Pattern** abstrai a origem dos dados, fornecendo uma interface unificada para acesso a dados:

- ✅ Abstrai fonte de dados (API, local, cache)
- ✅ Facilita testes com mocks
- ✅ Permite mudança de implementação

### 🏗️ Implementação

#### Interface Base

```dart
abstract class TodosRepository extends ChangeNotifier {
  // Estado atual (para UI reativa)
  List<Todo> get todos;

  // Operações CRUD
  Future<Result<List<Todo>>> get();
  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  });
  Future<Result<void>> delete(Todo todo);
  Future<Result<Todo>> getById(String id);
  Future<Result<Todo>> updateTodo(Todo todo);
}
```

#### Implementação Mock (Desenvolvimento)

```dart
class TodosRepositoryDev extends TodosRepository {
  final List<Todo> _todos = [];

  @override
  List<Todo> get todos => List.unmodifiable(_todos);

  @override
  Future<Result<List<Todo>>> get() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 500));
    
    return Result.ok(_todos);
  }

  @override
  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

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
    await Future.delayed(const Duration(milliseconds: 300));

    _todos.removeWhere((t) => t.id == todo.id);
    notifyListeners();

    return Result.ok(null);
  }

  @override
  Future<Result<Todo>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final todo = _todos.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception("Todo não encontrado"),
    );

    return Result.ok(todo);
  }

  @override
  Future<Result<Todo>> updateTodo(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _todos.indexWhere((t) => t.id == todo.id);
    
    if (index == -1) {
      return Result.error(Exception("Todo não encontrado"));
    }

    _todos[index] = todo;
    notifyListeners();

    return Result.ok(todo);
  }
}
```

#### Implementação Remota (API)

```dart
class TodosRepositoryRemote extends TodosRepository {
  final ApiClient _apiClient;
  final List<Todo> _cache = [];

  TodosRepositoryRemote({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  List<Todo> get todos => List.unmodifiable(_cache);

  @override
  Future<Result<List<Todo>>> get() async {
    try {
      final response = await _apiClient.get("/todos");
      
      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final todos = json.map((e) => Todo.fromJson(e)).toList();
        
        _cache.clear();
        _cache.addAll(todos);
        notifyListeners();
        
        return Result.ok(todos);
      } else {
        return Result.error(
          Exception("Falha ao carregar todos: ${response.statusCode}")
        );
      }
    } catch (e) {
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<Todo>> add({
    required String name,
    required String description,
    required bool done,
  }) async {
    try {
      final body = {
        'name': name,
        'description': description,
        'done': done,
      };

      final response = await _apiClient.post("/todos", body);
      
      if (response.statusCode == 201) {
        final todo = Todo.fromJson(jsonDecode(response.body));
        
        _cache.add(todo);
        notifyListeners();
        
        return Result.ok(todo);
      } else {
        return Result.error(
          Exception("Falha ao criar todo: ${response.statusCode}")
        );
      }
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
}
```

## 🏢 Use Case Pattern

### 📖 Conceito

**Use Cases** encapsulam regras de negócio específicas:

- ✅ Uma responsabilidade por classe
- ✅ Reutilizável entre diferentes interfaces
- ✅ Testável isoladamente

### 🏗️ Implementação

```dart
class TodoUpdateUseCase {
  final TodosRepository _todosRepository;

  TodoUpdateUseCase({
    required TodosRepository todosRepository,
  }) : _todosRepository = todosRepository;

  Future<Result<Todo>> updateTodo(Todo todo) async {
    // Validações de negócio
    if (todo.name.trim().isEmpty) {
      return Result.error(
        Exception("Nome do TODO não pode estar vazio")
      );
    }

    if (todo.description.length > 500) {
      return Result.error(
        Exception("Descrição muito longa (máximo 500 caracteres)")
      );
    }

    // Regra de negócio: todos marcados como concluídos
    // não podem ter descrição vazia
    if (todo.done && todo.description.trim().isEmpty) {
      return Result.error(
        Exception("TODOs concluídos devem ter descrição")
      );
    }

    // Delegação para o repository
    return await _todosRepository.updateTodo(todo);
  }

  Future<Result<void>> markAsCompleted(String todoId) async {
    // Buscar o todo atual
    final todoResult = await _todosRepository.getById(todoId);
    
    switch (todoResult) {
      case Ok<Todo>():
        final todo = todoResult.value;
        
        // Aplicar regra de negócio
        final updatedTodo = todo.copyWith(
          done: true,
          // Se não tiver descrição, adicionar uma padrão
          description: todo.description.trim().isEmpty 
            ? "Tarefa concluída em ${DateTime.now()}"
            : todo.description,
        );
        
        return await updateTodo(updatedTodo);
        
      case Error<Todo>():
        return Result.error(todoResult.error);
    }
  }
}
```

## 🔄 Observer Pattern (ChangeNotifier)

### 📖 Conceito

O **Observer Pattern** permite que objetos sejam notificados sobre mudanças de estado:

- ✅ ViewModels notificam Views sobre mudanças
- ✅ Repositories notificam ViewModels sobre atualizações
- ✅ UI reativa e eficiente

### 🏗️ Implementação

#### No ViewModel

```dart
class TodoViewmodel extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  void _updateTodos(List<Todo> newTodos) {
    _todos = newTodos;
    notifyListeners(); // Notifica observers
  }

  // Observa mudanças no repository
  TodoViewmodel({required TodosRepository repository}) {
    repository.addListener(() {
      _todos = repository.todos;
      notifyListeners();
    });
  }
}
```

#### Na View

```dart
class TodoScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.todoViewmodel, // Observer
        builder: (context, child) {
          // Rebuild automático quando ViewModel muda
          return ListView.builder(
            itemCount: widget.todoViewmodel.todos.length,
            itemBuilder: (context, index) {
              final todo = widget.todoViewmodel.todos[index];
              return TodoTile(todo: todo);
            },
          );
        },
      ),
    );
  }
}
```

## 🏭 Factory Pattern (Dependency Injection)

### 📖 Conceito

O **Factory Pattern** cria objetos sem especificar sua classe exata:

- ✅ Facilita troca de implementações
- ✅ Configuração centralizada
- ✅ Testabilidade aprimorada

### 🏗️ Implementação

```dart
// config/dependencies.dart
List<SingleChildWidget> get providersRemote {
  return [
    // Factory para ApiClient
    Provider(
      create: (context) => ApiClient(host: "api.example.com"),
    ),
    
    // Factory para Repository (implementação remota)
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryRemote(
        apiClient: context.read<ApiClient>(),
      ) as TodosRepository, // Interface abstrata
    ),
    
    ..._sharedProviders
  ];
}

List<SingleChildWidget> get providersLocal {
  return [
    // Factory para Repository (implementação mock)
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryDev() as TodosRepository,
    ),
    
    ..._sharedProviders
  ];
}

List<SingleChildWidget> get _sharedProviders {
  return [
    // Factory para Use Cases
    Provider(
      create: (context) => TodoUpdateUseCase(
        todosRepository: context.read<TodosRepository>(),
      ),
    ),
  ];
}
```

## 🎯 Naming Conventions

### 📁 Arquivos e Pastas
```
snake_case.dart           # Arquivos
snake_case/               # Pastas
feature_name_widget.dart  # Widgets
feature_name_screen.dart  # Screens
feature_name_viewmodel.dart # ViewModels
```

### 🏷️ Classes e Métodos
```dart
// Classes: PascalCase
class TodoViewmodel extends ChangeNotifier { }

// Métodos públicos: camelCase
void addTodo() { }

// Métodos privados: _camelCase
void _updateInternalState() { }

// Constantes: SCREAMING_SNAKE_CASE
static const int MAX_TODOS = 100;

// Variáveis: camelCase
final List<Todo> activeTodos = [];
```

### 🔧 Comandos e Resultados
```dart
// Commands: ação + substantivo
late Command1<Todo, String> loadTodo;
late Command1<void, Todo> deleteTodo;
late Command1<List<Todo>, void> refreshTodos;

// Results: sempre tipados
Future<Result<Todo>> getTodo(String id);
Future<Result<List<Todo>>> getAllTodos();
Future<Result<void>> removeTodo(Todo todo);
```

## ✅ Melhores Práticas

### 🎯 Commands
- ✅ Um command por ação
- ✅ Nomes descritivos (loadTodos, addTodo)
- ✅ Tratamento de erro em cada comando
- ✅ UI reativa baseada no estado do comando

### 📊 Results
- ✅ Sempre use Result para operações que podem falhar
- ✅ Pattern matching para tratamento
- ✅ Evite exceptions para controle de fluxo
- ✅ Logs detalhados em caso de erro

### 🏛️ Repositories
- ✅ Interface abstrata sempre
- ✅ Implementações separadas por ambiente
- ✅ Cache local quando apropriado
- ✅ Notificação de mudanças (ChangeNotifier)

### 🏢 Use Cases
- ✅ Uma responsabilidade por classe
- ✅ Validações de negócio centralizadas
- ✅ Reutilização entre features
- ✅ Testes unitários abrangentes

---

**Anterior:** [Estrutura do Projeto](./03-estrutura-projeto.md) | **Próximo:** [Guia de Desenvolvimento](./05-guia-desenvolvimento.md)
