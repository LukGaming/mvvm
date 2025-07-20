# 🔧 Troubleshooting

## 📋 Visão Geral

Este guia contém soluções para problemas comuns encontrados durante o desenvolvimento, testes e deploy do projeto MVVM Flutter.

## 🚨 Problemas Comuns

### 🔧 Problemas de Setup

#### ❌ Flutter Doctor Issues

**Problema**: `flutter doctor` mostra erros de configuração

**Soluções**:

```bash
# Verificar versão do Flutter
flutter --version

# Atualizar Flutter
flutter upgrade

# Limpar cache
flutter clean
flutter pub get

# Verificar configuração Android
flutter doctor --android-licenses

# Verificar configuração iOS (macOS)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### ❌ Problemas de Dependências

**Problema**: Conflitos de versões no `pubspec.yaml`

**Solução**:
```bash
# Limpar cache de dependências
flutter clean
rm pubspec.lock

# Reinstalar dependências
flutter pub get

# Verificar dependências desatualizadas
flutter pub outdated

# Atualizar dependências
flutter pub upgrade
```

**Problema**: Erro `version solving failed`

**Solução**:
```yaml
# pubspec.yaml - Use dependency overrides se necessário
dependency_overrides:
  meta: ^1.8.0
  collection: ^1.17.0
```

### 🏗️ Problemas de Arquitetura

#### ❌ ViewModel não atualiza a UI

**Problema**: Mudanças no ViewModel não refletem na interface

**Diagnóstico**:
```dart
// Verificar se está chamando notifyListeners()
class TodoViewmodel extends ChangeNotifier {
  void updateTodos(List<Todo> todos) {
    _todos = todos;
    notifyListeners(); // ⚠️ Não esquecer desta linha!
  }
}

// Verificar se está usando ListenableBuilder
Widget build(BuildContext context) {
  return ListenableBuilder(  // ✅ Correto
    listenable: viewModel,
    builder: (context, child) {
      return Text(viewModel.data);
    },
  );
}
```

**Solução Completa**:
```dart
class TodoViewmodel extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<void> loadTodos() async {
    try {
      final result = await repository.getTodos();
      switch (result) {
        case Ok<List<Todo>>():
          _todos = result.value;
          notifyListeners(); // ✅ Sempre chamar após mudança de estado
          break;
        case Error():
          // Handle error
          break;
      }
    } finally {
      notifyListeners(); // ✅ Garantir que UI seja atualizada
    }
  }
}
```

#### ❌ Commands não funcionam

**Problema**: Commands não executam ou não mostram estado correto

**Diagnóstico**:
```dart
// ❌ Problema comum: não aguardar a execução
onPressed: () {
  viewModel.command.execute(data); // Sem await
}

// ✅ Solução: aguardar se necessário
onPressed: () async {
  await viewModel.command.execute(data);
  // Alguma ação pós-execução se necessário
}
```

**Verificação de Estado**:
```dart
// Verificar estado do command na UI
ListenableBuilder(
  listenable: viewModel.command,
  builder: (context, child) {
    final command = viewModel.command;
    
    if (command.running) {
      return CircularProgressIndicator();
    }
    
    if (command.error) {
      return Text('Erro: ${command.result?.error}');
    }
    
    return ElevatedButton(
      onPressed: () => command.execute(data),
      child: Text('Executar'),
    );
  },
)
```

#### ❌ Result Pattern não funciona como esperado

**Problema**: Pattern matching não funciona

**Diagnóstico**:
```dart
// ❌ Problema: não usar pattern matching corretamente
final result = await repository.getData();
if (result is Ok) {  // Pode não funcionar como esperado
  // ...
}

// ✅ Solução: usar switch expressions
switch (result) {
  case Ok<DataType>():
    final data = result.value;
    // Handle success
    break;
  case Error<DataType>():
    final error = result.error;
    // Handle error
    break;
}
```

### 🧪 Problemas de Teste

#### ❌ Testes falhando com mocks

**Problema**: Mocks não funcionam como esperado

**Solução**:
```dart
// ✅ Setup correto de mocks
class MockRepository extends Mock implements TodosRepository {}

void main() {
  late MockRepository mockRepository;
  late TodoViewmodel viewModel;

  setUp(() {
    mockRepository = MockRepository();
    viewModel = TodoViewmodel(repository: mockRepository);
  });

  test('should load todos', () async {
    // Arrange
    final expectedTodos = [Todo(id: '1', name: 'Test')];
    when(() => mockRepository.getTodos())
        .thenAnswer((_) async => Result.ok(expectedTodos));

    // Act
    await viewModel.load.execute();

    // Assert
    verify(() => mockRepository.getTodos()).called(1);
    expect(viewModel.todos, equals(expectedTodos));
  });
}
```

#### ❌ Testes de Widget falham

**Problema**: Widget tests não encontram elementos

**Solução**:
```dart
testWidgets('should display todo', (tester) async {
  // Arrange
  const todo = Todo(id: '1', name: 'Test Todo');
  
  // Act
  await tester.pumpWidget(
    MaterialApp(  // ✅ Sempre wrap com MaterialApp
      home: TodoTile(todo: todo),
    ),
  );
  
  await tester.pumpAndSettle(); // ✅ Aguardar animações
  
  // Assert
  expect(find.text('Test Todo'), findsOneWidget);
});
```

### 🌐 Problemas de Rede/API

#### ❌ Timeout ou conexão recusada

**Problema**: API não responde ou timeout

**Diagnóstico**:
```dart
// Adicionar logs detalhados no ApiClient
class ApiClient {
  Future<http.Response> get(String endpoint) async {
    final url = Uri.http(host, endpoint);
    
    try {
      print('🌐 GET: $url'); // Debug log
      
      final response = await _client.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout for $url');
        },
      );
      
      print('📊 Response: ${response.statusCode}'); // Debug log
      return response;
      
    } catch (e) {
      print('❌ Error: $e'); // Debug log
      rethrow;
    }
  }
}
```

**Soluções**:

1. **Verificar conectividade**:
```dart
// Adicionar dependency: connectivity_plus
import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasConnection() async {
  final connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}
```

2. **Configurar retry automático**:
```dart
Future<Result<T>> _withRetry<T>(Future<Result<T>> Function() operation) async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      return await operation();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      
      await Future.delayed(Duration(seconds: attempts * 2)); // Backoff
    }
  }
  
  throw Exception('Max retry attempts reached');
}
```

#### ❌ CORS errors (Web)

**Problema**: Erros de CORS ao fazer requisições da web

**Soluções**:

1. **Configurar proxy no desenvolvimento**:
```bash
# Usar proxy durante desenvolvimento
flutter run -d chrome --web-port 8080 --web-hostname localhost
```

2. **Configurar headers no backend**:
```dart
// Backend deve incluir headers CORS
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
```

### 🚀 Problemas de Performance

#### ❌ UI travando ou lenta

**Problema**: Interface não responsiva

**Diagnóstico**:
```dart
// Usar Performance Overlay
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: true, // Debug performance
      // ...
    );
  }
}
```

**Soluções**:

1. **Evitar builds desnecessários**:
```dart
// ❌ Problema: rebuild toda a lista
ListView.builder(
  itemBuilder: (context, index) {
    return ListenableBuilder(  // Rebuilds toda vez
      listenable: viewModel,
      builder: (context, child) => TodoTile(todo: viewModel.todos[index]),
    );
  },
)

// ✅ Solução: mover listener para nível superior
ListenableBuilder(
  listenable: viewModel,
  builder: (context, child) {
    return ListView.builder(  // Só rebuilda quando necessário
      itemBuilder: (context, index) => TodoTile(todo: viewModel.todos[index]),
    );
  },
)
```

2. **Usar const constructors**:
```dart
// ✅ Sempre usar const quando possível
const TodoTile({
  super.key,
  required this.todo,
});
```

3. **Evitar operações pesadas na UI thread**:
```dart
// ✅ Usar compute para operações pesadas
Future<List<Todo>> processLargeTodoList(List<Map<String, dynamic>> data) async {
  return await compute(_processData, data);
}

List<Todo> _processData(List<Map<String, dynamic>> data) {
  // Processamento pesado aqui
  return data.map((e) => Todo.fromJson(e)).toList();
}
```

### 📱 Problemas de Build

#### ❌ Build fails no Android

**Problema**: Erro de build para Android

**Soluções Comuns**:

1. **Limpar build cache**:
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter build apk
```

2. **Problemas de Gradle**:
```bash
# android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-all.zip

# android/build.gradle
classpath 'com.android.tools.build:gradle:8.1.0'
```

3. **Multidex issues**:
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'com.android.support:multidex:1.0.3'
}
```

#### ❌ Build fails no iOS

**Problema**: Erro de build para iOS

**Soluções**:

1. **Limpar DerivedData**:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter build ios
```

2. **Problemas de assinatura**:
```bash
# Verificar Team ID no Xcode
open ios/Runner.xcworkspace
# Project Settings → Signing & Capabilities
```

### 🔐 Problemas de Estado

#### ❌ Estado compartilhado inconsistente

**Problema**: Estados diferentes entre ViewModels

**Solução**: Usar Repository como fonte única de verdade

```dart
// ✅ Repository notifica mudanças
abstract class TodosRepository extends ChangeNotifier {
  List<Todo> get todos;
  
  Future<Result<Todo>> updateTodo(Todo todo) async {
    // Update logic
    notifyListeners(); // Notifica todos os listeners
    return result;
  }
}

// ✅ ViewModels observam o Repository
class TodoViewmodel extends ChangeNotifier {
  TodoViewmodel({required TodosRepository repository}) {
    repository.addListener(() {
      _todos = repository.todos; // Sempre sincronizado
      notifyListeners();
    });
  }
}
```

## 🔍 Ferramentas de Debug

### 📊 Flutter Inspector

```bash
# Executar com inspector
flutter run --debug
# Abrir DevTools no navegador
```

### 📝 Logging Avançado

```dart
// lib/utils/logger.dart
import 'package:logging/logging.dart';

class AppLogger {
  static final _loggers = <String, Logger>{};
  
  static Logger getLogger(String name) {
    return _loggers.putIfAbsent(name, () {
      final logger = Logger(name);
      logger.onRecord.listen((record) {
        final emoji = _getEmoji(record.level);
        print('$emoji ${record.level.name}: ${record.loggerName}: ${record.message}');
        
        if (record.error != null) {
          print('Error: ${record.error}');
        }
        
        if (record.stackTrace != null) {
          print('Stack: ${record.stackTrace}');
        }
      });
      return logger;
    });
  }
  
  static String _getEmoji(Level level) {
    if (level >= Level.SEVERE) return '🔴';
    if (level >= Level.WARNING) return '🟡';
    if (level >= Level.INFO) return '🔵';
    return '⚪';
  }
}

// Uso
final _log = AppLogger.getLogger('TodoViewmodel');
_log.info('Loading todos...');
_log.warning('Failed to load todos', error);
```

### 🧪 Debug Commands

```dart
// Adicionar debug info aos Commands
abstract class Command<T> extends ChangeNotifier {
  String get debugInfo => '''
Command State:
  - Running: $running
  - Completed: $completed
  - Error: $error
  - Result: ${result?.runtimeType}
  ''';
}

// Uso no debug
print(viewModel.loadCommand.debugInfo);
```

## 📋 Checklist de Debug

### 🔍 Quando algo não funciona:

1. **✅ Verificar logs**: Sempre olhar o console primeiro
2. **✅ Estado dos Commands**: Verificar `running`, `completed`, `error`
3. **✅ Network**: Testar conectividade e endpoints
4. **✅ Mocks**: Verificar se mocks estão configurados corretamente
5. **✅ Listeners**: Confirmar que `notifyListeners()` está sendo chamado
6. **✅ Pattern Matching**: Verificar uso correto de `switch`
7. **✅ Async/Await**: Confirmar uso correto de operações assíncronas

### 🧪 Para problemas de teste:

1. **✅ Setup**: Verificar configuração de mocks e dependências
2. **✅ Pump**: Usar `pumpAndSettle()` para widgets
3. **✅ Matchers**: Verificar se está usando matchers corretos
4. **✅ Isolation**: Garantir que testes são isolados
5. **✅ Cleanup**: Verificar se está limpando recursos

### 🚀 Para problemas de build:

1. **✅ Clean**: Sempre começar com `flutter clean`
2. **✅ Versions**: Verificar compatibilidade de versões
3. **✅ Platform**: Testar em plataforma específica
4. **✅ Dependencies**: Verificar conflitos de dependências
5. **✅ Config**: Validar configurações de build

## 🆘 Onde Buscar Ajuda

### 📚 Documentação Oficial
- [Flutter Documentation](https://docs.flutter.dev)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)

### 🌐 Comunidades
- [Flutter Community](https://github.com/fluttercommunity)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Flutter Discord](https://discord.gg/flutter)

### 🔧 Issues Conhecidos
- [Flutter Issues](https://github.com/flutter/flutter/issues)
- [Provider Issues](https://github.com/rrousselGit/provider/issues)

### 📞 Suporte do Projeto
- Criar issue no repositório do projeto
- Consultar documentação interna
- Contatar equipe de desenvolvimento

---

**Anterior:** [Deployment](./07-deployment.md) | **Voltar ao:** [Início](./README.md)
