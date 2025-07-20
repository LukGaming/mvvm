# 📱 Visão Geral do Projeto MVVM Flutter

## 🎯 Sobre o Projeto

Este é um projeto Flutter que implementa um sistema de gerenciamento de TODOs utilizando a arquitetura **MVVM (Model-View-ViewModel)** com padrões modernos de desenvolvimento.

## 🛠️ Tecnologias Principais

### Framework e Linguagem
- **Flutter**: Framework principal para desenvolvimento multiplataforma
- **Dart**: Linguagem de programação (SDK ^3.5.3)

### Arquitetura e Padrões
- **MVVM**: Separação clara entre View, ViewModel e Model
- **Command Pattern**: Para gerenciar ações e estados
- **Result Pattern**: Para tratamento de erros de forma funcional
- **Repository Pattern**: Para abstração de dados

### Dependências Principais

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  json_annotation: ^4.9.0      # Serialização JSON
  freezed_annotation: ^2.4.4   # Classes imutáveis
  go_router: ^14.8.1           # Navegação
  provider: ^6.1.4             # Gerenciamento de estado
  logging: ^1.3.0              # Sistema de logs
  mocktail: ^1.0.4             # Mocks para testes

dev_dependencies:
  json_serializable: ^6.9.3    # Geração de código JSON
  freezed: ^2.5.8              # Geração de classes imutáveis
  build_runner: ^2.4.14       # Geração de código
  flutter_lints: ^4.0.0       # Linting
```

## 🏗️ Arquitetura do Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      View       │────│   ViewModel     │────│     Model       │
│   (Widgets)     │    │   (Commands)    │    │ (Repository)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Camadas da Aplicação

1. **UI Layer** (`lib/ui/`)
   - Widgets e Screens
   - ViewModels
   - Gerenciamento de estado da interface

2. **Domain Layer** (`lib/domain/`)
   - Models (entidades de negócio)
   - Use Cases (regras de negócio)

3. **Data Layer** (`lib/data/`)
   - Repositories (abstração de dados)
   - Services (API, Local Storage)

4. **Utils** (`lib/utils/`)
   - Commands (Command Pattern)
   - Result (Result Pattern)
   - Typedefs e utilitários

## 📊 Funcionalidades Implementadas

### Core Features
- ✅ Listagem de TODOs
- ✅ Criação de novos TODOs
- ✅ Edição de TODOs existentes
- ✅ Exclusão de TODOs
- ✅ Marcação como concluído/pendente
- ✅ Visualização de detalhes

### Recursos Técnicos
- ✅ Navegação com Go Router
- ✅ Injeção de dependências com Provider
- ✅ Testes unitários
- ✅ Múltiplos ambientes (dev, staging, prod)
- ✅ API mock e integração remota
- ✅ Tratamento de erros robusto

## 🌍 Ambientes de Execução

O projeto suporta múltiplos ambientes:

### Development (Desenvolvimento)
```bash
flutter run --flavor development -t lib/main_development.dart
```
- Usa dados locais/mock
- Logs detalhados
- Debug habilitado

### Staging (Homologação)
```bash
flutter run --flavor staging -t lib/main_staging.dart
```
- Conecta com API de staging
- Logs moderados
- Testes de integração

### Production (Produção)
```bash
flutter run --flavor production -t lib/main.dart
```
- API de produção
- Logs mínimos
- Performance otimizada

## 🎨 Padrões de Design Implementados

### 1. Command Pattern
```dart
// Exemplo de uso
final command = Command1<Todo, String>(_loadTodo);
await command.execute(todoId);

if (command.completed) {
  // Sucesso
  final todo = command.result!.value;
} else if (command.error) {
  // Erro
  final error = command.result!.error;
}
```

### 2. Result Pattern
```dart
// Retorno padronizado
Future<Result<Todo>> getTodo(String id) async {
  try {
    final todo = await api.getTodo(id);
    return Result.ok(todo);
  } catch (e) {
    return Result.error(e);
  }
}
```

### 3. Repository Pattern
```dart
abstract class TodosRepository extends ChangeNotifier {
  Future<Result<List<Todo>>> get();
  Future<Result<Todo>> add({required String name, ...});
  Future<Result<void>> delete(Todo todo);
}
```

## 📱 Plataformas Suportadas

- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Web** (Chrome, Firefox, Safari)
- ✅ **Windows** (Windows 10+)
- ✅ **macOS** (macOS 10.14+)
- ✅ **Linux** (Ubuntu 20.04+)

## 🚀 Primeiros Passos

1. **Pré-requisitos**
   ```bash
   # Verificar instalação do Flutter
   flutter doctor
   ```

2. **Instalação**
   ```bash
   git clone [repository-url]
   cd mvvm
   flutter pub get
   ```

3. **Execução**
   ```bash
   # Desenvolvimento
   flutter run -t lib/main_development.dart
   
   # Ou usar o VS Code launch.json configurado
   ```

4. **Testes**
   ```bash
   flutter test
   ```

## 🎯 Objetivos de Aprendizado

Após estudar este projeto, você deve compreender:

- ✅ Implementação prática da arquitetura MVVM em Flutter
- ✅ Como usar Command Pattern para gerenciar ações
- ✅ Result Pattern para tratamento de erros
- ✅ Injeção de dependências com Provider
- ✅ Navegação com Go Router
- ✅ Testes unitários em Flutter
- ✅ Organização de código em projetos grandes

---

**Próximo:** [Arquitetura MVVM](./02-arquitetura-mvvm.md)
