# 🎯 Quick Reference Card

## 🚀 Comandos Essenciais

### 🏃‍♂️ Execução
```bash
# Desenvolvimento (dados mock)
flutter run -t lib/main_development.dart

# Staging (API de teste)
flutter run -t lib/main_staging.dart

# Produção
flutter run -t lib/main.dart --release

# Web
flutter run -d chrome -t lib/main_development.dart
```

### 🧪 Testes
```bash
# Todos os testes
flutter test

# Com coverage
flutter test --coverage

# Testes específicos
flutter test test/ui/todos/viewmodels/

# Watch mode
flutter test --watch
```

### 🏗️ Build
```bash
# Android APK
flutter build apk -t lib/main.dart --release

# iOS
flutter build ios -t lib/main.dart --release

# Web
flutter build web -t lib/main.dart --release
```

### 🔧 Manutenção
```bash
# Limpar cache
flutter clean && flutter pub get

# Atualizar dependências
flutter pub upgrade

# Verificar saúde do projeto
flutter doctor

# Analisar código
flutter analyze
```

## 🏗️ Padrões de Implementação

### 📊 ViewModel Template
```dart
class FeatureViewmodel extends ChangeNotifier {
  FeatureViewmodel({
    required Repository repository,
    required UseCase useCase,
  }) : _repository = repository, _useCase = useCase {
    load = Command0(_load)..execute();
    action = Command1(_action);
    
    _repository.addListener(() {
      _items = _repository.items;
      notifyListeners();
    });
  }

  final Repository _repository;
  final UseCase _useCase;

  late final Command0<List<Item>> load;
  late final Command1<Item, Params> action;

  List<Item> _items = [];
  List<Item> get items => _items;

  Future<Result<List<Item>>> _load() async {
    try {
      final result = await _repository.getAll();
      switch (result) {
        case Ok<List<Item>>():
          _items = result.value;
          break;
        case Error():
          _log.warning("Error loading", result.error);
          break;
      }
      return result;
    } catch (e) {
      return Result.error(e as Exception);
    } finally {
      notifyListeners();
    }
  }
}
```

### 🏛️ Repository Template
```dart
abstract class Repository<T> extends ChangeNotifier {
  List<T> get items;
  Future<Result<List<T>>> getAll();
  Future<Result<T>> getById(String id);
  Future<Result<T>> create(T item);
  Future<Result<T>> update(T item);
  Future<Result<void>> delete(T item);
}

class RepositoryImpl extends Repository<Item> {
  final ApiClient _apiClient;
  final List<Item> _cache = [];

  @override
  List<Item> get items => List.unmodifiable(_cache);

  @override
  Future<Result<List<Item>>> getAll() async {
    try {
      final response = await _apiClient.get('/items');
      if (response.statusCode == 200) {
        final items = (jsonDecode(response.body) as List)
            .map((e) => Item.fromJson(e))
            .toList();
        
        _cache.clear();
        _cache.addAll(items);
        notifyListeners();
        
        return Result.ok(items);
      } else {
        return Result.error(Exception("Failed to load"));
      }
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
}
```

### 🎯 Command Usage
```dart
// No ViewModel
late final Command1<Todo, (String, String, bool)> addTodo;

addTodo = Command1((params) async {
  final (name, description, done) = params;
  return await _repository.add(
    name: name,
    description: description,
    done: done,
  );
});

// Na View
ListenableBuilder(
  listenable: viewModel.addTodo,
  builder: (context, child) {
    final command = viewModel.addTodo;
    
    return ElevatedButton(
      onPressed: command.running ? null : () {
        command.execute(("New Todo", "Description", false));
      },
      child: command.running 
        ? CircularProgressIndicator()
        : Text("Add Todo"),
    );
  },
)
```

### 📊 Result Pattern Usage
```dart
// Retornando Result
Future<Result<Todo>> getTodo(String id) async {
  try {
    final todo = await apiClient.getTodo(id);
    return Result.ok(todo);
  } catch (e) {
    return Result.error(e as Exception);
  }
}

// Consumindo Result
final result = await repository.getTodo("1");
switch (result) {
  case Ok<Todo>():
    final todo = result.value;
    // Handle success
    break;
  case Error<Todo>():
    final error = result.error;
    // Handle error
    break;
}
```

## 🧪 Snippets de Teste

### 🎯 ViewModel Test
```dart
void main() {
  late MyViewmodel viewModel;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    viewModel = MyViewmodel(repository: mockRepository);
  });

  test('should load items successfully', () async {
    // Arrange
    final items = [Item(id: '1', name: 'Test')];
    when(() => mockRepository.getAll())
        .thenAnswer((_) async => Result.ok(items));

    // Act
    await viewModel.load.execute();

    // Assert
    expect(viewModel.load.completed, isTrue);
    expect(viewModel.items, equals(items));
    verify(() => mockRepository.getAll()).called(1);
  });
}
```

### 🎨 Widget Test
```dart
testWidgets('should display item name', (tester) async {
  // Arrange
  const item = Item(id: '1', name: 'Test Item');
  
  // Act
  await tester.pumpWidget(
    MaterialApp(home: ItemTile(item: item)),
  );
  
  // Assert
  expect(find.text('Test Item'), findsOneWidget);
});
```

## 📁 Estrutura de Arquivos

```
lib/
├── main.dart                    # Production entry
├── main_development.dart        # Dev entry
├── main_staging.dart           # Staging entry
├── config/
│   └── dependencies.dart       # DI configuration
├── data/
│   ├── repositories/           # Data access layer
│   └── services/              # External services
├── domain/
│   ├── models/                # Business entities
│   └── use_cases/             # Business logic
├── ui/
│   └── feature/
│       ├── viewmodels/        # Presentation logic
│       └── widgets/           # UI components
├── routing/
│   ├── router.dart            # Route configuration
│   └── routes.dart            # Route definitions
└── utils/
    ├── commands/              # Command pattern
    ├── result/                # Result pattern
    └── typedefs/              # Type definitions
```

## 🔧 Dependency Injection

```dart
// config/dependencies.dart
List<SingleChildWidget> get providers {
  return [
    // Services
    Provider(create: (_) => ApiClient(host: "api.com")),
    
    // Repositories
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryRemote(
        apiClient: context.read(),
      ) as TodosRepository,
    ),
    
    // Use Cases
    Provider(
      create: (context) => TodoUpdateUseCase(
        repository: context.read(),
      ),
    ),
  ];
}

// main.dart
void main() {
  runApp(
    MultiProvider(
      providers: providers,
      child: MyApp(),
    ),
  );
}
```

## 🎨 UI Patterns

### 📱 Screen Structure
```dart
class FeatureScreen extends StatefulWidget {
  final FeatureViewmodel viewmodel;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Feature")),
      body: Column(
        children: [
          // Input widgets
          FeatureInputWidget(viewmodel: widget.viewmodel),
          
          // List with state management
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewmodel,
              builder: (context, child) {
                return FeatureList(
                  items: widget.viewmodel.items,
                  onAction: _handleAction,
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

### 🔄 Loading States
```dart
ListenableBuilder(
  listenable: viewModel.loadCommand,
  builder: (context, child) {
    final command = viewModel.loadCommand;
    
    if (command.running) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (command.error) {
      return ErrorWidget(
        error: command.result?.error,
        onRetry: () => command.execute(),
      );
    }
    
    return ContentWidget(data: viewModel.data);
  },
)
```

## ⚡ Performance Tips

- ✅ Use `const` constructors when possible
- ✅ Move `ListenableBuilder` up in widget tree
- ✅ Avoid creating objects in `build` method
- ✅ Use `ListView.builder` for large lists
- ✅ Implement proper `dispose` methods
- ✅ Cache expensive computations
- ✅ Use `compute` for heavy operations

---

**💡 Dica**: Mantenha este card como referência rápida durante o desenvolvimento!
