# 🚀 Deployment e Configuração de Ambientes

## 📋 Visão Geral

Este projeto suporta múltiplos ambientes com configurações específicas para cada um:

- **🔧 Development**: Desenvolvimento local com dados mock
- **🧪 Staging**: Homologação com API de teste  
- **🏭 Production**: Produção com API real

## 🌍 Configuração de Ambientes

### 📁 Estrutura de Entry Points

```
lib/
├── main.dart              # Produção (padrão)
├── main_development.dart  # Desenvolvimento
└── main_staging.dart      # Staging/Homologação
```

### 🔧 Development Environment

#### `main_development.dart`
```dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/main.dart';
import 'package:provider/provider.dart';

void main() {
  // Configurar logging detalhado para desenvolvimento
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('Stack trace: ${record.stackTrace}');
    }
  });

  runApp(
    MultiProvider(
      providers: providersLocal, // Usa dados mock locais
      child: const MyApp(),
    ),
  );
}
```

**Características:**
- ✅ Logs detalhados (Level.FINE)
- ✅ Dados mock/locais
- ✅ Hot reload rápido
- ✅ Sem dependência de rede
- ✅ Debug prints visíveis

#### Comando de execução:
```bash
flutter run -t lib/main_development.dart
```

### 🧪 Staging Environment

#### `main_staging.dart`
```dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/main.dart';
import 'package:provider/provider.dart';

void main() {
  // Configurar logging moderado para staging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}');
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
  });

  runApp(
    MultiProvider(
      providers: providersStaging, // API de teste
      child: const MyApp(),
    ),
  );
}
```

**Características:**
- ✅ Logs moderados (Level.INFO)
- ✅ API de staging/teste
- ✅ Simula ambiente de produção
- ✅ Testes de integração
- ✅ Validação de fluxos completos

#### Comando de execução:
```bash
flutter run -t lib/main_staging.dart
```

### 🏭 Production Environment

#### `main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mvvm/config/dependencies.dart';
import 'package:mvvm/routing/router.dart';
import 'package:provider/provider.dart';

void main() {
  // Configurar logging mínimo para produção
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    // Em produção, você pode enviar logs para um serviço como Crashlytics
    if (record.level >= Level.SEVERE) {
      // Reportar erros críticos
      _reportError(record);
    }
  });

  runApp(
    MultiProvider(
      providers: providersRemote, // API de produção
      child: const MyApp(),
    ),
  );
}

void _reportError(LogRecord record) {
  // Implementar integração com serviços de monitoramento
  // Ex: Firebase Crashlytics, Sentry, etc.
  debugPrint('CRITICAL ERROR: ${record.message}');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter MVVM Demo',
      debugShowCheckedModeBanner: false, // Remover banner de debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      routerConfig: routerConfig(),
    );
  }
}
```

**Características:**
- ✅ Logs mínimos (Level.WARNING)
- ✅ API de produção
- ✅ Performance otimizada
- ✅ Monitoramento de erros
- ✅ Sem debug banner

#### Comando de execução:
```bash
flutter run -t lib/main.dart --release
```

## ⚙️ Configuração de Dependencies

### 📦 `config/dependencies.dart`

```dart
import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_dev.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_remote.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Configuração para ambiente de produção
List<SingleChildWidget> get providersRemote {
  return [
    Provider(
      create: (context) => ApiClient(
        host: "your-production-api.com", // URL da API de produção
        timeout: const Duration(seconds: 30),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryRemote(
        apiClient: context.read(),
      ) as TodosRepository,
    ),
    ..._sharedProviders
  ];
}

// Configuração para ambiente de staging
List<SingleChildWidget> get providersStaging {
  return [
    Provider(
      create: (context) => ApiClient(
        host: "your-staging-api.com", // URL da API de staging
        timeout: const Duration(seconds: 15),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryRemote(
        apiClient: context.read(),
      ) as TodosRepository,
    ),
    ..._sharedProviders
  ];
}

// Configuração para ambiente de desenvolvimento
List<SingleChildWidget> get providersLocal {
  return [
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryDev() as TodosRepository,
    ),
    ..._sharedProviders
  ];
}

// Providers compartilhados entre todos os ambientes
List<SingleChildWidget> get _sharedProviders {
  return [
    Provider(
      create: (context) => TodoUpdateUseCase(
        todosRepository: context.read(),
      ),
    ),
    // Adicione outros providers compartilhados aqui
  ];
}
```

## 🏗️ Build e Deploy

### 📱 Android

#### Configuração de Flavors (`android/app/build.gradle`)

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.mvvm"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        debug {
            applicationIdSuffix ".debug"
            debuggable true
            signingConfig signingConfigs.debug
        }
        
        staging {
            applicationIdSuffix ".staging"
            debuggable true
            signingConfig signingConfigs.debug
            // Configurações específicas para staging
        }
        
        release {
            debuggable false
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }

    flavorDimensions "environment"
    
    productFlavors {
        development {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        
        production {
            dimension "environment"
        }
    }
}
```

#### Comandos de Build Android

```bash
# Development
flutter build apk --flavor development -t lib/main_development.dart

# Staging
flutter build apk --flavor staging -t lib/main_staging.dart

# Production
flutter build apk --flavor production -t lib/main.dart --release

# Android App Bundle para Play Store
flutter build appbundle --flavor production -t lib/main.dart --release
```

### 🍎 iOS

#### Configuração de Schemes

No Xcode, criar schemes separados:

1. **Abrir projeto iOS**: `open ios/Runner.xcworkspace`
2. **Product → Scheme → Manage Schemes**
3. **Criar novos schemes**:
   - `Runner-Development`
   - `Runner-Staging`  
   - `Runner-Production`

#### Comandos de Build iOS

```bash
# Development
flutter build ios --flavor development -t lib/main_development.dart

# Staging
flutter build ios --flavor staging -t lib/main_staging.dart

# Production
flutter build ios --flavor production -t lib/main.dart --release

# Para App Store
flutter build ipa --flavor production -t lib/main.dart --release
```

### 🌐 Web

#### Build para Web

```bash
# Development
flutter build web -t lib/main_development.dart

# Staging
flutter build web -t lib/main_staging.dart

# Production
flutter build web -t lib/main.dart --release --web-renderer html
```

#### Deploy na Vercel/Netlify

**`vercel.json`**:
```json
{
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

### 🖥️ Desktop

#### Windows

```bash
# Development
flutter build windows -t lib/main_development.dart

# Production
flutter build windows -t lib/main.dart --release
```

#### macOS

```bash
# Development
flutter build macos -t lib/main_development.dart

# Production
flutter build macos -t lib/main.dart --release
```

#### Linux

```bash
# Development
flutter build linux -t lib/main_development.dart

# Production
flutter build linux -t lib/main.dart --release
```

## 🔒 Configuração de Assinatura

### 📱 Android Signing

#### `android/key.properties`
```properties
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=your-key-alias
storeFile=path-to-your-keystore.jks
```

#### `android/app/build.gradle`
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 🍎 iOS Signing

Configurar no Xcode:
1. **Project Settings → Signing & Capabilities**
2. **Configurar Team e Bundle Identifier**
3. **Certificados de desenvolvimento/distribuição**

## 🤖 CI/CD com GitHub Actions

### `.github/workflows/main.yml`

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run analyzer
      run: flutter analyze
      
    - name: Run tests
      run: flutter test --coverage
      
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build APK
      run: flutter build apk --flavor production -t lib/main.dart --release
      
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-production-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build iOS
      run: flutter build ios --flavor production -t lib/main.dart --release --no-codesign
      
    - name: Upload iOS build
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build Web
      run: flutter build web -t lib/main.dart --release
      
    - name: Deploy to Vercel
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.ORG_ID }}
        vercel-project-id: ${{ secrets.PROJECT_ID }}
        working-directory: ./build/web
```

## 📊 Monitoramento e Analytics

### 🔥 Firebase Integration

#### `pubspec.yaml`
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_crashlytics: ^3.4.9
  firebase_analytics: ^10.7.4
```

#### Configuração

```dart
// lib/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Configurar Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Errors fora do Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  static Future<void> logEvent(String name, Map<String, Object> parameters) async {
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  static Future<void> setUserId(String userId) async {
    await FirebaseAnalytics.instance.setUserId(id: userId);
  }
}
```

#### Uso no main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase apenas em produção
  if (kReleaseMode) {
    await FirebaseService.initialize();
  }
  
  runApp(MyApp());
}
```

## 🚀 Scripts de Automação

### 📜 `scripts/build.sh`

```bash
#!/bin/bash

set -e

ENVIRONMENT=${1:-development}
PLATFORM=${2:-android}

echo "Building for $ENVIRONMENT environment on $PLATFORM platform..."

case $ENVIRONMENT in
  "development")
    TARGET="lib/main_development.dart"
    FLAVOR="development"
    ;;
  "staging")
    TARGET="lib/main_staging.dart"
    FLAVOR="staging"
    ;;
  "production")
    TARGET="lib/main.dart"
    FLAVOR="production"
    ;;
  *)
    echo "Invalid environment: $ENVIRONMENT"
    exit 1
    ;;
esac

case $PLATFORM in
  "android")
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build apk --flavor $FLAVOR -t $TARGET --release
    else
      flutter build apk --flavor $FLAVOR -t $TARGET
    fi
    ;;
  "ios")
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build ios --flavor $FLAVOR -t $TARGET --release
    else
      flutter build ios --flavor $FLAVOR -t $TARGET
    fi
    ;;
  "web")
    if [ "$ENVIRONMENT" = "production" ]; then
      flutter build web -t $TARGET --release
    else
      flutter build web -t $TARGET
    fi
    ;;
  *)
    echo "Invalid platform: $PLATFORM"
    exit 1
    ;;
esac

echo "Build completed successfully!"
```

### 📜 `scripts/deploy.sh`

```bash
#!/bin/bash

set -e

ENVIRONMENT=${1:-staging}

echo "Deploying $ENVIRONMENT environment..."

# Run tests first
echo "Running tests..."
flutter test

# Build for web
echo "Building web..."
flutter build web -t lib/main_${ENVIRONMENT}.dart --release

# Deploy based on environment
case $ENVIRONMENT in
  "staging")
    echo "Deploying to staging..."
    # Deploy to staging server
    ;;
  "production")
    echo "Deploying to production..."
    # Deploy to production server
    ;;
  *)
    echo "Invalid environment: $ENVIRONMENT"
    exit 1
    ;;
esac

echo "Deployment completed successfully!"
```

### 🎯 Comandos de Uso

```bash
# Dar permissão de execução
chmod +x scripts/build.sh scripts/deploy.sh

# Build development para Android
./scripts/build.sh development android

# Build production para iOS
./scripts/build.sh production ios

# Deploy staging
./scripts/deploy.sh staging

# Deploy production
./scripts/deploy.sh production
```

## ✅ Checklist de Deploy

### 🔍 Pré-Deploy
- [ ] Todos os testes passando
- [ ] Code review aprovado
- [ ] Análise estática sem erros
- [ ] Documentação atualizada
- [ ] Changelog atualizado

### 🏗️ Build
- [ ] Build limpo sem warnings
- [ ] Tamanho do app dentro do limite
- [ ] Performance testada
- [ ] Configurações corretas por ambiente

### 🚀 Deploy
- [ ] Backup da versão anterior
- [ ] Deploy em staging primeiro
- [ ] Testes de aceitação
- [ ] Monitoramento ativo
- [ ] Rollback plan pronto

### 📊 Pós-Deploy
- [ ] Métricas de performance
- [ ] Logs de erro zerados
- [ ] Feedback dos usuários
- [ ] Documentação atualizada

---

**Anterior:** [Testes](./06-testes.md) | **Próximo:** [Troubleshooting](./08-troubleshooting.md)
