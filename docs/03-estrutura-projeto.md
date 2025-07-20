# 📁 Estrutura do Projeto

## 🗂️ Organização Geral

```
mvvm/
├── 📱 android/                    # Configurações Android
├── 🍎 ios/                        # Configurações iOS  
├── 🖥️ windows/                    # Configurações Windows
├── 🐧 linux/                      # Configurações Linux
├── 🖥️ macos/                      # Configurações macOS
├── 🌐 web/                        # Configurações Web
├── 🏗️ build/                      # Arquivos de build (gerados)
├── 📋 test/                       # Testes unitários
├── 🛠️ server/                     # Mock server (JSON Server)
├── 📚 docs/                       # Documentação do projeto
├── 📂 lib/                        # Código fonte principal
├── 📄 pubspec.yaml               # Dependências e configurações
├── 📄 analysis_options.yaml      # Regras de análise de código
└── 📄 README.md                  # Documentação básica
```

## 📂 Detalhamento da Pasta `lib/`

### 🎯 Estrutura Principal

```
lib/
├── 🚀 main.dart                   # Entry point produção
├── 🚀 main_development.dart       # Entry point desenvolvimento  
├── 🚀 main_staging.dart           # Entry point staging
├── ⚙️ config/                     # Configurações da aplicação
├── 📊 data/                       # Camada de dados
├── 🏢 domain/                     # Camada de domínio
├── 🎨 ui/                         # Camada de interface
├── 🧭 routing/                    # Configuração de rotas
└── 🛠️ utils/                      # Utilitários e helpers
```

## 📊 Camada de Dados (`data/`)

### Estrutura Detalhada

```
data/
├── 📚 repositories/               # Implementações de repositórios
│   └── todos/
│       ├── todos_repository.dart           # Interface abstrata
│       ├── todos_repository_dev.dart       # Implementação mock
│       └── todos_repository_remote.dart    # Implementação API
└── 🌐 services/                   # Serviços externos
    └── api/
        ├── api_client.dart                 # Cliente HTTP
        └── models/
            └── todo/
                ├── todo_api_model.dart     # Modelo API
                └── todo_api_model.freezed.dart
```

### 📚 Repositories

#### Interface Base (`todos_repository.dart`)
```dart
abstract class TodosRepository extends ChangeNotifier {
  List<Todo> get todos;                    // Estado atual dos todos
  
  Future<Result<List<Todo>>> get();        // Buscar todos
  Future<Result<Todo>> add({...});         // Criar novo todo
  Future<Result<void>> delete(Todo todo);  // Deletar todo
  Future<Result<Todo>> getById(String id); // Buscar por ID
  Future<Result<Todo>> updateTodo(Todo todo); // Atualizar todo
}
```

#### Implementação Mock (`todos_repository_dev.dart`)
- Dados simulados em memória
- Útil para desenvolvimento e testes
- Não requer conexão de rede

#### Implementação Remota (`todos_repository_remote.dart`)
- Conecta com API real
- Usa `ApiClient` para chamadas HTTP
- Implementa cache local

### 🌐 Services

#### API Client (`api_client.dart`)
```dart
class ApiClient {
  final String host;
  final http.Client _client;
  
  ApiClient({required this.host});
  
  Future<http.Response> get(String endpoint) async {
    final url = Uri.http(host, endpoint);
    return await _client.get(url);
  }
  
  Future<http.Response> post(String endpoint, Object body) async {
    final url = Uri.http(host, endpoint);
    return await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}
```

## 🏢 Camada de Domínio (`domain/`)

### Estrutura Detalhada

```
domain/
├── 📋 models/                     # Entidades de negócio
│   └── todo.dart                  # Modelo Todo
└── 🔧 use_cases/                  # Regras de negócio
    └── todo_update_use_case.dart  # Caso de uso para atualização
```

### 📋 Models

#### Todo Entity (`todo.dart`)
```dart
class Todo {
  final String id;        // Identificador único
  final String name;      // Nome/título do todo
  final String description; // Descrição detalhada
  final bool done;        // Status de conclusão

  const Todo({
    required this.id,
    required this.name,
    required this.description,
    required this.done,
  });

  // Serialização JSON
  factory Todo.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
  
  // Cópia com modificações (imutabilidade)
  Todo copyWith({...}) { ... }
}
```

### 🔧 Use Cases

#### TodoUpdateUseCase (`todo_update_use_case.dart`)
```dart
class TodoUpdateUseCase {
  final TodosRepository _todosRepository;

  TodoUpdateUseCase({required TodosRepository todosRepository})
      : _todosRepository = todosRepository;

  Future<Result<Todo>> updateTodo(Todo todo) async {
    // Validações de negócio
    if (todo.name.trim().isEmpty) {
      return Result.error(Exception("Nome não pode estar vazio"));
    }
    
    // Delegação para o repository
    return await _todosRepository.updateTodo(todo);
  }
}
```

## 🎨 Camada de Interface (`ui/`)

### Estrutura Detalhada

```
ui/
├── 📋 todo/                       # Funcionalidade de TODOs
│   ├── viewmodels/
│   │   └── todo_viewmodel.dart    # ViewModel principal
│   └── widgets/
│       ├── todo_screen.dart       # Tela principal
│       ├── todo_tile.dart         # Item da lista
│       ├── todos_list.dart        # Lista de todos
│       └── add_todo_widget.dart   # Widget para adicionar
└── 📝 todo_details/               # Detalhes do TODO
    ├── viewmodels/
    │   └── todo_details_viewmodel.dart
    └── widgets/
        ├── todo_details_screen.dart
        ├── todo_name_widget.dart
        ├── todo_description.dart
        └── edit_todo_widget.dart
```

### 📋 Feature: Todo

#### ViewModel (`todo_viewmodel.dart`)
```dart
class TodoViewmodel extends ChangeNotifier {
  // Dependências injetadas
  final TodosRepository _todosRepository;
  final TodoUpdateUseCase _todoUpdateUseCase;

  // Commands para ações
  late Commmand0 load;                              // Carregar todos
  late Command1<Todo, (String, String, bool)> addTodo;  // Adicionar todo
  late Command1<void, Todo> deleteTodo;             // Deletar todo
  late Command1<Todo, Todo> updateTodo;             // Atualizar todo

  // Estado interno
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;  // Estado exposto
}
```

#### Screen (`todo_screen.dart`)
```dart
class TodoScreen extends StatefulWidget {
  final TodoViewmodel todoViewmodel;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todos")),
      body: Column(
        children: [
          AddTodoWidget(todoViewmodel: widget.todoViewmodel),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.todoViewmodel,
              builder: (context, child) {
                return TodosList(
                  todos: widget.todoViewmodel.todos,
                  todoViewmodel: widget.todoViewmodel,
                  onDeleteTodo: _onDeleteTodo,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🧭 Roteamento (`routing/`)

### Estrutura

```
routing/
├── router.dart          # Configuração do GoRouter
└── routes.dart          # Definição de rotas
```

#### Routes Definition (`routes.dart`)
```dart
class Routes {
  static const String todos = "/todos";
  
  static String todoDetails(String id) => "/todos/$id";
}
```

#### Router Configuration (`router.dart`)
```dart
GoRouter routerConfig() {
  return GoRouter(
    initialLocation: Routes.todos,
    routes: [
      GoRoute(
        path: Routes.todos,
        builder: (context, state) {
          return TodoScreen(
            todoViewmodel: TodoViewmodel(
              todosRepository: context.read(),
              todoUpdateUseCase: context.read(),
            ),
          );
        },
        routes: [
          GoRoute(
            path: ":id",
            builder: (context, state) {
              final todoId = state.pathParameters["id"]!;
              return TodoDetailsScreen(
                todoDetailsViewModel: TodoDetailsViewModel(
                  todosRepository: context.read(),
                  todoUpdateUseCase: context.read(),
                )..load.execute(todoId),
              );
            },
          ),
        ],
      ),
    ],
  );
}
```

## 🛠️ Utilitários (`utils/`)

### Estrutura

```
utils/
├── 🎯 commands/              # Command Pattern
│   └── commands.dart
├── 📊 result/                # Result Pattern
│   └── result.dart
└── 📝 typedefs/              # Type definitions
    └── todos.dart
```

### 🎯 Commands (`commands.dart`)

#### Command0 (sem parâmetros)
```dart
class Commmand0<Output> extends Command<Output> {
  final CommandAction0<Output> action;
  
  Commmand0(this.action);
  
  Future<void> execute() async {
    await _execute(() => action());
  }
}
```

#### Command1 (com parâmetros)
```dart
class Command1<Output, Input> extends Command<Output> {
  final CommandAction1<Output, Input> action;

  Command1(this.action);

  Future<void> execute(Input params) async {
    await _execute(() => action(params));
  }
}
```

### 📊 Result (`result.dart`)

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

## ⚙️ Configurações (`config/`)

### Dependencies (`dependencies.dart`)

```dart
// Providers para ambiente remoto
List<SingleChildWidget> get providersRemote {
  return [
    Provider(
      create: (context) => ApiClient(host: "192.168.1.106"),
    ),
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryRemote(
        apiClient: context.read(),
      ) as TodosRepository,
    ),
    ..._sharedProviders
  ];
}

// Providers para ambiente local/desenvolvimento
List<SingleChildWidget> get providersLocal {
  return [
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryDev() as TodosRepository,
    ),
    ..._sharedProviders
  ];
}

// Providers compartilhados
List<SingleChildWidget> get _sharedProviders {
  return [
    Provider(
      create: (context) => TodoUpdateUseCase(
        todosRepository: context.read(),
      ),
    ),
  ];
}
```

## 📋 Testes (`test/`)

### Estrutura

```
test/
├── 📊 data/                  # Testes da camada de dados
├── 🏢 domain/                # Testes da camada de domínio  
├── 🎨 ui/                    # Testes da camada de interface
│   └── todos/
│       └── viewmodels/
│           └── todo_viewmodel_test.dart
├── 🛠️ utils/                 # Testes dos utilitários
└── 🧪 mock/                  # Mocks para testes
```

### Exemplo de Teste (`todo_viewmodel_test.dart`)

```dart
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
    test("Should add Todo", () async {
      expect(todoViewmodel.todos, isEmpty);

      await todoViewmodel.addTodo.execute((
        "Novo todo",
        "Todo description",
        false,
      ));

      expect(todoViewmodel.todos, isNotEmpty);
      expect(todoViewmodel.todos.first.name, contains("Novo todo"));
    });
  });
}
```

## 🛠️ Server Mock (`server/`)

### db.json
```json
{
  "todos": [
    {
      "id": "1",
      "name": "Primeira tarefa",
      "description": "Descrição da primeira tarefa",
      "done": false
    }
  ]
}
```

### Comando para execução
```bash
cd server
npx json-server db.json --host 0.0.0.0 --port 3000
```

## 📁 Convenções de Nomenclatura

### 📂 Pastas
- `snake_case` para nomes de pastas
- Organização por feature/funcionalidade
- Separação clara entre camadas

### 📄 Arquivos
- `snake_case.dart` para arquivos Dart
- Sufixos descritivos:
  - `_screen.dart` para telas
  - `_widget.dart` para widgets
  - `_viewmodel.dart` para view models
  - `_repository.dart` para repositories
  - `_test.dart` para testes

### 🏷️ Classes
- `PascalCase` para classes
- Nomes descritivos e específicos
- Sufixos para identificar responsabilidade:
  - `ViewModel` para view models
  - `Repository` para repositories
  - `UseCase` para casos de uso

## 🎯 Melhores Práticas

### ✅ Organização
- Uma classe por arquivo
- Importações organizadas (Dart, packages, projeto)
- Comentários em código complexo

### ✅ Dependências
- Injeção através do construtor
- Use interfaces/abstrações
- Evite dependências circulares

### ✅ Estado
- Imutabilidade quando possível
- Estado interno privado
- Exposição controlada através de getters

### ✅ Testes
- Um teste por funcionalidade
- Arrange-Act-Assert pattern
- Mocks para dependências externas

---

**Anterior:** [Arquitetura MVVM](./02-arquitetura-mvvm.md) | **Próximo:** [Padrões de Código](./04-padroes-codigo.md)
