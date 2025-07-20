# 📚 Glossário e Referências

## 🔤 Glossário de Termos

### 🏗️ Arquitetura e Padrões

**MVVM (Model-View-ViewModel)**
- Padrão arquitetural que separa a lógica de apresentação (ViewModel) da interface do usuário (View) e dos dados (Model)

**Command Pattern**
- Padrão que encapsula uma ação como um objeto, permitindo parametrizar, enfileirar e gerenciar o estado de execução

**Result Pattern**
- Padrão que representa o resultado de uma operação que pode falhar, evitando exceptions para controle de fluxo

**Repository Pattern**
- Padrão que abstrai a origem dos dados, fornecendo uma interface unificada para acesso a dados

**Observer Pattern**
- Padrão que permite notificar múltiplos objetos sobre mudanças de estado

**Use Case Pattern**
- Padrão que encapsula regras de negócio específicas em classes focadas e reutilizáveis

### 🎯 Componentes do Flutter

**ChangeNotifier**
- Classe que fornece notificações quando há mudanças, base para o padrão Observer no Flutter

**ListenableBuilder**
- Widget que reconstrói quando um Listenable (como ChangeNotifier) notifica mudanças

**Provider**
- Sistema de injeção de dependências e gerenciamento de estado para Flutter

**StatefulWidget**
- Widget que pode ter estado mutável durante seu ciclo de vida

**StatelessWidget**
- Widget imutável que não mantém estado interno

### 🛠️ Termos Técnicos

**Hot Reload**
- Funcionalidade que permite atualizar código em tempo real sem perder o estado da aplicação

**Widget Tree**
- Hierarquia de widgets que compõe a interface do usuário

**Build Context**
- Referência à localização de um widget na árvore de widgets

**Dependency Injection**
- Técnica de fornecer dependências de um objeto externamente ao invés de criá-las internamente

**Mock**
- Objeto simulado usado em testes para substituir dependências reais

## 📖 Referências Técnicas

### 🏗️ Arquitetura MVVM

```dart
// Exemplo de implementação MVVM
class TodoViewmodel extends ChangeNotifier {  // ViewModel
  final TodosRepository _repository;          // Model
  
  TodoViewmodel({required TodosRepository repository})
      : _repository = repository;
}

class TodoScreen extends StatefulWidget {     // View
  final TodoViewmodel viewModel;
  // ...
}
```

### 🎯 Command Pattern Completo

```dart
// Interface base para commands
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;
  
  bool get running => _running;
  bool get completed => _result is Ok;
  bool get error => _result is Error;
  Result<T>? get result => _result;
}

// Command sem parâmetros
class Command0<T> extends Command<T> {
  final Future<Result<T>> Function() _action;
  
  Command0(this._action);
  
  Future<void> execute() async {
    if (_running) return;
    
    _running = true;
    _result = null;
    notifyListeners();
    
    try {
      _result = await _action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

// Command com parâmetros
class Command1<TResult, TParam> extends Command<TResult> {
  final Future<Result<TResult>> Function(TParam) _action;
  
  Command1(this._action);
  
  Future<void> execute(TParam param) async {
    if (_running) return;
    
    _running = true;
    _result = null;
    notifyListeners();
    
    try {
      _result = await _action(param);
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}
```

### 📊 Result Pattern Implementação

```dart
// Classe base Result
abstract class Result<T> {
  const Result();
  
  factory Result.ok(T value) = Ok._;
  factory Result.error(Exception error) = Error._;
}

// Resultado de sucesso
final class Ok<T> extends Result<T> {
  final T value;
  const Ok._(this.value);
}

// Resultado de erro
final class Error<T> extends Result<T> {
  final Exception error;
  const Error._(this.error);
}

// Extensions úteis
extension ResultExtensions<T> on Result<T> {
  bool get isOk => this is Ok<T>;
  bool get isError => this is Error<T>;
  
  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;
  Exception? get errorOrNull => this is Error<T> ? (this as Error<T>).error : null;
}
```

### 🏛️ Repository Pattern Template

```dart
// Interface abstrata
abstract class Repository<T, TId> extends ChangeNotifier {
  List<T> get items;
  
  Future<Result<List<T>>> getAll();
  Future<Result<T>> getById(TId id);
  Future<Result<T>> create(T item);
  Future<Result<T>> update(T item);
  Future<Result<void>> delete(TId id);
}

// Implementação base
abstract class BaseRepository<T, TId> extends Repository<T, TId> {
  final List<T> _items = [];
  
  @override
  List<T> get items => List.unmodifiable(_items);
  
  @override
  Future<Result<List<T>>> getAll() async {
    try {
      final items = await fetchItems();
      _items.clear();
      _items.addAll(items);
      notifyListeners();
      return Result.ok(_items);
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
  
  // Método abstrato para implementação específica
  Future<List<T>> fetchItems();
}
```

## 📋 Convenções de Código

### 🏷️ Nomenclatura

```dart
// Classes: PascalCase
class TodoViewmodel { }
class ApiClient { }

// Métodos e variáveis: camelCase
void loadTodos() { }
final List<Todo> activeTodos = [];

// Métodos privados: _camelCase
void _updateInternalState() { }

// Constantes: SCREAMING_SNAKE_CASE
static const int MAX_RETRY_ATTEMPTS = 3;

// Arquivos: snake_case
todo_viewmodel.dart
api_client.dart

// Pastas: snake_case
view_models/
use_cases/
```

### 📁 Estrutura de Arquivos

```
lib/
├── config/                 # Configurações
├── data/                   # Camada de dados
│   ├── repositories/       # Implementações de repositórios
│   └── services/          # Serviços externos (API, storage)
├── domain/                # Camada de domínio
│   ├── models/            # Entidades de negócio
│   └── use_cases/         # Regras de negócio
├── ui/                    # Camada de interface
│   ├── feature_name/      # Agrupado por funcionalidade
│   │   ├── viewmodels/    # ViewModels da feature
│   │   └── widgets/       # Widgets da feature
├── routing/               # Configuração de rotas
└── utils/                 # Utilitários e helpers
    ├── commands/          # Command Pattern
    ├── result/            # Result Pattern
    └── typedefs/          # Definições de tipos
```

### 🧪 Convenções de Teste

```dart
// Nome do arquivo: nome_original_test.dart
todo_viewmodel_test.dart
api_client_test.dart

// Estrutura do teste
void main() {
  group('Feature Tests', () {
    late MyClass subject;
    late MockDependency mockDependency;

    setUp(() {
      // Configuração comum
    });

    test('Should do X when Y happens', () async {
      // Arrange - Configurar
      
      // Act - Executar
      
      // Assert - Verificar
    });
  });
}

// Nomes descritivos
test('Should add todo when valid data is provided', () {});
test('Should return error when name is empty', () {});
test('Should notify listeners when state changes', () {});
```

## 🔗 Links Úteis

### 📚 Documentação Oficial

- **Flutter**: https://docs.flutter.dev/
- **Dart**: https://dart.dev/guides
- **Provider**: https://pub.dev/packages/provider
- **Go Router**: https://pub.dev/packages/go_router
- **Mocktail**: https://pub.dev/packages/mocktail

### 🛠️ Ferramentas de Desenvolvimento

- **Flutter DevTools**: https://docs.flutter.dev/tools/devtools
- **VS Code Flutter Extension**: https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter
- **Android Studio Flutter Plugin**: https://plugins.jetbrains.com/plugin/9212-flutter

### 🏗️ Recursos de Arquitetura

- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **MVVM Pattern**: https://docs.microsoft.com/en-us/xamarin/xamarin-forms/enterprise-application-patterns/mvvm
- **Repository Pattern**: https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design

### 🧪 Recursos de Teste

- **Flutter Testing**: https://docs.flutter.dev/testing
- **Widget Testing**: https://docs.flutter.dev/cookbook/testing/widget
- **Integration Testing**: https://docs.flutter.dev/testing/integration-tests

## 📊 Métricas e Benchmarks

### 🎯 Objetivos de Performance

```yaml
# Métricas alvo para o projeto
Performance Targets:
  - App startup time: < 3 segundos
  - Navigation time: < 300ms
  - API response time: < 2 segundos
  - Memory usage: < 100MB
  - Frame rate: 60 FPS consistente

Test Coverage:
  - Unit tests: > 90%
  - Widget tests: > 70%
  - Integration tests: > 50%

Code Quality:
  - Cyclomatic complexity: < 10
  - Code duplication: < 5%
  - Technical debt ratio: < 10%
```

### 📈 Ferramentas de Monitoramento

```dart
// Exemplo de instrumentação
class PerformanceMonitor {
  static void trackOperation(String name, Function operation) {
    final stopwatch = Stopwatch()..start();
    
    try {
      operation();
    } finally {
      stopwatch.stop();
      _log.info('$name took ${stopwatch.elapsedMilliseconds}ms');
    }
  }
  
  static Future<T> trackAsync<T>(String name, Future<T> operation) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      return await operation;
    } finally {
      stopwatch.stop();
      _log.info('$name took ${stopwatch.elapsedMilliseconds}ms');
    }
  }
}

// Uso
PerformanceMonitor.trackOperation('Load todos', () {
  return repository.loadTodos();
});
```

## 🎓 Materiais de Estudo

### 📖 Livros Recomendados

1. **"Clean Architecture" by Robert C. Martin**
   - Princípios de arquitetura limpa
   - Separação de responsabilidades

2. **"Design Patterns" by Gang of Four**
   - Padrões de design fundamentais
   - Command, Observer, Repository patterns

3. **"Flutter in Action" by Eric Windmill**
   - Desenvolvimento Flutter prático
   - Boas práticas e padrões

### 🎥 Cursos e Vídeos

- **Flutter Official Channel**: https://www.youtube.com/c/flutterdev
- **ResoCoder Flutter Tutorials**: https://www.youtube.com/c/ResoCoder
- **Reso Coder Clean Architecture**: https://resocoder.com/flutter-clean-architecture-tdd/

### 📝 Artigos Técnicos

- **MVVM in Flutter**: https://medium.com/flutter-community/mvvm-in-flutter-2729e845c39f
- **State Management Approaches**: https://docs.flutter.dev/development/data-and-backend/state-mgmt/options
- **Testing Best Practices**: https://medium.com/flutter-community/testing-best-practices-in-flutter-6b6b3b50e1b1

## 🚀 Próximos Passos

### 📈 Evoluções Futuras

1. **Implementar Cache Local**
   - SQLite para persistência offline
   - Sincronização com API

2. **Adicionar Analytics**
   - Firebase Analytics
   - Crash reporting

3. **Implementar Push Notifications**
   - Firebase Cloud Messaging
   - Notificações locais

4. **Adicionar Internacionalização**
   - Suporte a múltiplos idiomas
   - Localização de datas/números

5. **Melhorar Acessibilidade**
   - Screen reader support
   - Navegação por teclado

### 🛠️ Ferramentas Avançadas

```dart
// Exemplo de estrutura para cache
abstract class CacheManager<T> {
  Future<T?> get(String key);
  Future<void> set(String key, T value, {Duration? ttl});
  Future<void> remove(String key);
  Future<void> clear();
}

// Exemplo de analytics
abstract class AnalyticsService {
  Future<void> logEvent(String name, Map<String, dynamic> parameters);
  Future<void> setUserId(String userId);
  Future<void> setUserProperty(String name, String value);
}
```

---

**Voltar ao:** [Índice Principal](./README.md)
