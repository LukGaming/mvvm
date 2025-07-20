# 🚀 Guia de Desenvolvimento

## 📋 Visão Geral

Este guia demonstra como adicionar novas funcionalidades ao projeto seguindo os padrões estabelecidos. Usaremos como exemplo a implementação de um sistema de **Categorias** para os TODOs.

## 🎯 Exemplo: Implementando Categorias

### 📝 Requisitos
- Adicionar categorias aos TODOs
- Listar todas as categorias
- Filtrar TODOs por categoria
- CRUD completo de categorias

### 🏗️ Passo 1: Criando o Model (Domain Layer)

#### 1.1 Criar a entidade Category

```dart
// lib/domain/models/category.dart
class Category {
  final String id;
  final String name;
  final String description;
  final String color; // Código hexadecimal da cor

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      color: json["color"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

#### 1.2 Atualizar o modelo Todo

```dart
// lib/domain/models/todo.dart
class Todo {
  final String id;
  final String name;
  final String description;
  final bool done;
  final String? categoryId; // Nova propriedade

  const Todo({
    required this.id,
    required this.name,
    required this.description,
    required this.done,
    this.categoryId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      done: json["done"],
      categoryId: json["categoryId"], // Adicionar ao parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'done': done,
      'categoryId': categoryId, // Adicionar ao JSON
    };
  }

  Todo copyWith({
    String? id,
    String? name,
    String? description,
    bool? done,
    String? categoryId,
  }) {
    return Todo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      done: done ?? this.done,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
```

### 🏗️ Passo 2: Criando o Repository (Data Layer)

#### 2.1 Interface do Repository

```dart
// lib/data/repositories/categories/categories_repository.dart
import 'package:flutter/material.dart';
import 'package:mvvm/utils/result/result.dart';
import 'package:mvvm/domain/models/category.dart';

abstract class CategoriesRepository extends ChangeNotifier {
  List<Category> get categories;

  Future<Result<List<Category>>> get();
  
  Future<Result<Category>> add({
    required String name,
    required String description,
    required String color,
  });

  Future<Result<void>> delete(Category category);
  
  Future<Result<Category>> getById(String id);
  
  Future<Result<Category>> updateCategory(Category category);
}
```

#### 2.2 Implementação Mock (Development)

```dart
// lib/data/repositories/categories/categories_repository_dev.dart
import 'dart:math';
import 'package:mvvm/data/repositories/categories/categories_repository.dart';
import 'package:mvvm/domain/models/category.dart';
import 'package:mvvm/utils/result/result.dart';

class CategoriesRepositoryDev extends CategoriesRepository {
  final List<Category> _categories = [
    const Category(
      id: "1",
      name: "Trabalho",
      description: "Tarefas relacionadas ao trabalho",
      color: "#FF5722",
    ),
    const Category(
      id: "2",
      name: "Pessoal",
      description: "Tarefas pessoais",
      color: "#2196F3",
    ),
    const Category(
      id: "3",
      name: "Estudos",
      description: "Tarefas de estudo e aprendizado",
      color: "#4CAF50",
    ),
  ];

  @override
  List<Category> get categories => List.unmodifiable(_categories);

  @override
  Future<Result<List<Category>>> get() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Result.ok(_categories);
  }

  @override
  Future<Result<Category>> add({
    required String name,
    required String description,
    required String color,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final category = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      color: color,
    );

    _categories.add(category);
    notifyListeners();

    return Result.ok(category);
  }

  @override
  Future<Result<void>> delete(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _categories.removeWhere((c) => c.id == category.id);
    notifyListeners();

    return Result.ok(null);
  }

  @override
  Future<Result<Category>> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final category = _categories.firstWhere((c) => c.id == id);
      return Result.ok(category);
    } catch (e) {
      return Result.error(Exception("Categoria não encontrada"));
    }
  }

  @override
  Future<Result<Category>> updateCategory(Category category) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _categories.indexWhere((c) => c.id == category.id);
    
    if (index == -1) {
      return Result.error(Exception("Categoria não encontrada"));
    }

    _categories[index] = category;
    notifyListeners();

    return Result.ok(category);
  }
}
```

### 🏗️ Passo 3: Criando Use Cases (Domain Layer)

#### 3.1 Use Case para validações de categoria

```dart
// lib/domain/use_cases/category_validation_use_case.dart
import 'package:mvvm/data/repositories/categories/categories_repository.dart';
import 'package:mvvm/domain/models/category.dart';
import 'package:mvvm/utils/result/result.dart';

class CategoryValidationUseCase {
  final CategoriesRepository _categoriesRepository;

  CategoryValidationUseCase({
    required CategoriesRepository categoriesRepository,
  }) : _categoriesRepository = categoriesRepository;

  Future<Result<Category>> validateAndSave(Category category) async {
    // Validação: nome não pode estar vazio
    if (category.name.trim().isEmpty) {
      return Result.error(
        Exception("Nome da categoria não pode estar vazio")
      );
    }

    // Validação: nome deve ter pelo menos 3 caracteres
    if (category.name.trim().length < 3) {
      return Result.error(
        Exception("Nome da categoria deve ter pelo menos 3 caracteres")
      );
    }

    // Validação: cor deve ser válida
    if (!_isValidColor(category.color)) {
      return Result.error(
        Exception("Cor inválida. Use formato hexadecimal (#RRGGBB)")
      );
    }

    // Validação: nome único
    final duplicateExists = _categoriesRepository.categories
        .any((c) => c.name.toLowerCase() == category.name.toLowerCase() 
                    && c.id != category.id);

    if (duplicateExists) {
      return Result.error(
        Exception("Já existe uma categoria com este nome")
      );
    }

    // Se passou em todas as validações, salvar
    return await _categoriesRepository.updateCategory(category);
  }

  bool _isValidColor(String color) {
    final colorRegex = RegExp(r'^#[0-9A-Fa-f]{6}$');
    return colorRegex.hasMatch(color);
  }

  Future<Result<void>> validateBeforeDelete(Category category) async {
    // Aqui você poderia verificar se existem TODOs usando esta categoria
    // e impedir a exclusão se necessário
    
    // Por enquanto, apenas permite a exclusão
    return await _categoriesRepository.delete(category);
  }
}
```

### 🏗️ Passo 4: Criando o ViewModel

#### 4.1 Categories ViewModel

```dart
// lib/ui/categories/viewmodels/categories_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mvvm/data/repositories/categories/categories_repository.dart';
import 'package:mvvm/domain/models/category.dart';
import 'package:mvvm/domain/use_cases/category_validation_use_case.dart';
import 'package:mvvm/utils/commands/commands.dart';
import 'package:mvvm/utils/result/result.dart';

class CategoriesViewmodel extends ChangeNotifier {
  CategoriesViewmodel({
    required CategoriesRepository categoriesRepository,
    required CategoryValidationUseCase categoryValidationUseCase,
  })  : _categoriesRepository = categoriesRepository,
        _categoryValidationUseCase = categoryValidationUseCase {
    
    // Inicializar commands
    load = Commmand0(_load)..execute();
    addCategory = Command1(_addCategory);
    deleteCategory = Command1(_deleteCategory);
    updateCategory = Command1(_updateCategory);
    
    // Observar mudanças no repository
    _categoriesRepository.addListener(() {
      _categories = _categoriesRepository.categories;
      notifyListeners();
    });
  }

  final CategoriesRepository _categoriesRepository;
  final CategoryValidationUseCase _categoryValidationUseCase;

  // Commands
  late final Commmand0<List<Category>> load;
  late final Command1<Category, (String, String, String)> addCategory;
  late final Command1<void, Category> deleteCategory;
  late final Command1<Category, Category> updateCategory;

  // Estado
  List<Category> _categories = [];
  List<Category> get categories => _categories;

  // Filtros
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  List<Category> get filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    
    return _categories.where((category) =>
        category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        category.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  final _log = Logger("CategoriesViewmodel");

  // Implementações
  Future<Result<List<Category>>> _load() async {
    try {
      final result = await _categoriesRepository.get();

      switch (result) {
        case Ok<List<Category>>():
          _categories = result.value;
          _log.fine("Categorias carregadas: ${_categories.length}");
          break;
        case Error():
          _log.warning("Erro ao carregar categorias", result.error);
          break;
      }

      return result;
    } on Exception catch (error, stackTrace) {
      _log.warning("Falha ao carregar categorias", error, stackTrace);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<Category>> _addCategory((String, String, String) params) async {
    final (name, description, color) = params;

    try {
      final result = await _categoriesRepository.add(
        name: name,
        description: description,
        color: color,
      );

      switch (result) {
        case Ok<Category>():
          _categories.add(result.value);
          _log.fine("Categoria criada: ${result.value.name}");
          break;
        case Error():
          _log.warning("Erro ao criar categoria", result.error);
          break;
      }

      return result;
    } on Exception catch (error, stackTrace) {
      _log.warning("Falha ao criar categoria", error, stackTrace);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<void>> _deleteCategory(Category category) async {
    try {
      final result = await _categoryValidationUseCase.validateBeforeDelete(category);

      switch (result) {
        case Ok<void>():
          _categories.remove(category);
          _log.fine("Categoria removida: ${category.name}");
          break;
        case Error():
          _log.warning("Erro ao remover categoria", result.error);
          break;
      }

      return result;
    } on Exception catch (error, stackTrace) {
      _log.warning("Falha ao remover categoria", error, stackTrace);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  Future<Result<Category>> _updateCategory(Category category) async {
    try {
      final result = await _categoryValidationUseCase.validateAndSave(category);

      switch (result) {
        case Ok<Category>():
          final index = _categories.indexWhere((c) => c.id == category.id);
          if (index != -1) {
            _categories[index] = result.value;
          }
          _log.fine("Categoria atualizada: ${result.value.name}");
          break;
        case Error():
          _log.warning("Erro ao atualizar categoria", result.error);
          break;
      }

      return result;
    } on Exception catch (error, stackTrace) {
      _log.warning("Falha ao atualizar categoria", error, stackTrace);
      return Result.error(error);
    } finally {
      notifyListeners();
    }
  }

  // Métodos utilitários
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = "";
    notifyListeners();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
```

### 🏗️ Passo 5: Criando a Interface (UI Layer)

#### 5.1 Categories Screen

```dart
// lib/ui/categories/widgets/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:mvvm/ui/categories/viewmodels/categories_viewmodel.dart';
import 'package:mvvm/ui/categories/widgets/add_category_widget.dart';
import 'package:mvvm/ui/categories/widgets/categories_list.dart';
import 'package:mvvm/ui/categories/widgets/category_search_bar.dart';

class CategoriesScreen extends StatefulWidget {
  final CategoriesViewmodel categoriesViewmodel;

  const CategoriesScreen({
    super.key,
    required this.categoriesViewmodel,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    
    // Observar resultados dos commands
    widget.categoriesViewmodel.deleteCategory.addListener(_onDeleteResult);
  }

  @override
  void dispose() {
    widget.categoriesViewmodel.deleteCategory.removeListener(_onDeleteResult);
    super.dispose();
  }

  void _onDeleteResult() {
    final command = widget.categoriesViewmodel.deleteCategory;
    
    if (command.running) {
      // Mostrar loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: IntrinsicHeight(
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    } else {
      // Fechar loading dialog
      Navigator.of(context).pop();
      
      if (command.error) {
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro: ${command.result?.error}"),
            backgroundColor: Colors.red,
          ),
        );
      } else if (command.completed) {
        // Mostrar sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Categoria removida com sucesso"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorias"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          CategorySearchBar(
            categoriesViewmodel: widget.categoriesViewmodel,
          ),
          
          // Lista de categorias
          Expanded(
            child: ListenableBuilder(
              listenable: widget.categoriesViewmodel.load,
              builder: (context, child) {
                final command = widget.categoriesViewmodel.load;
                
                if (command.running) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (command.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text("Erro: ${command.result?.error}"),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => command.execute(),
                          child: const Text("Tentar novamente"),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListenableBuilder(
                  listenable: widget.categoriesViewmodel,
                  builder: (context, child) {
                    return CategoriesList(
                      categories: widget.categoriesViewmodel.filteredCategories,
                      categoriesViewmodel: widget.categoriesViewmodel,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nova Categoria"),
        content: AddCategoryWidget(
          categoriesViewmodel: widget.categoriesViewmodel,
        ),
      ),
    );
  }
}
```

#### 5.2 Category List Widget

```dart
// lib/ui/categories/widgets/categories_list.dart
import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/category.dart';
import 'package:mvvm/ui/categories/viewmodels/categories_viewmodel.dart';
import 'package:mvvm/ui/categories/widgets/category_tile.dart';

class CategoriesList extends StatelessWidget {
  final List<Category> categories;
  final CategoriesViewmodel categoriesViewmodel;

  const CategoriesList({
    super.key,
    required this.categories,
    required this.categoriesViewmodel,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              categoriesViewmodel.searchQuery.isEmpty
                  ? "Nenhuma categoria encontrada"
                  : "Nenhuma categoria corresponde à pesquisa",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            if (categoriesViewmodel.searchQuery.isNotEmpty)
              ElevatedButton(
                onPressed: () => categoriesViewmodel.clearSearch(),
                child: const Text("Limpar pesquisa"),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return CategoryTile(
          category: categories[index],
          categoriesViewmodel: categoriesViewmodel,
        );
      },
    );
  }
}
```

#### 5.3 Category Tile Widget

```dart
// lib/ui/categories/widgets/category_tile.dart
import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/category.dart';
import 'package:mvvm/ui/categories/viewmodels/categories_viewmodel.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final CategoriesViewmodel categoriesViewmodel;

  const CategoryTile({
    super.key,
    required this.category,
    required this.categoriesViewmodel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColor(),
          child: Text(
            category.name.isNotEmpty ? category.name[0].toUpperCase() : "?",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: category.description.isNotEmpty 
            ? Text(category.description)
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onMenuSelected(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text("Editar"),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Excluir", style: TextStyle(color: Colors.red)),
                dense: true,
              ),
            ),
          ],
        ),
        onTap: () => _onTap(context),
      ),
    );
  }

  Color _getColor() {
    try {
      return Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        _showEditDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _onTap(BuildContext context) {
    // Navegar para detalhes da categoria ou lista de TODOs desta categoria
  }

  void _showEditDialog(BuildContext context) {
    // Implementar dialog de edição
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar exclusão"),
        content: Text("Deseja realmente excluir a categoria \"${category.name}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              categoriesViewmodel.deleteCategory.execute(category);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }
}
```

### 🏗️ Passo 6: Atualizando Configurações

#### 6.1 Adicionar ao Dependencies

```dart
// lib/config/dependencies.dart
List<SingleChildWidget> get _sharedProviders {
  return [
    // Existing providers...
    Provider(
      create: (context) => TodoUpdateUseCase(
        todosRepository: context.read(),
      ),
    ),
    
    // New providers for categories
    ChangeNotifierProvider(
      create: (context) => CategoriesRepositoryDev() as CategoriesRepository,
    ),
    Provider(
      create: (context) => CategoryValidationUseCase(
        categoriesRepository: context.read(),
      ),
    ),
  ];
}
```

#### 6.2 Adicionar Routes

```dart
// lib/routing/routes.dart
class Routes {
  static const String todos = "/todos";
  static const String categories = "/categories";
  
  static String todoDetails(String id) => "/todos/$id";
  static String categoryDetails(String id) => "/categories/$id";
}
```

#### 6.3 Atualizar Router

```dart
// lib/routing/router.dart
GoRouter routerConfig() {
  return GoRouter(
    initialLocation: Routes.todos,
    routes: [
      // Existing routes...
      
      GoRoute(
        path: Routes.categories,
        builder: (context, state) {
          return CategoriesScreen(
            categoriesViewmodel: CategoriesViewmodel(
              categoriesRepository: context.read(),
              categoryValidationUseCase: context.read(),
            ),
          );
        },
      ),
    ],
  );
}
```

### 🏗️ Passo 7: Criando Testes

#### 7.1 Teste do ViewModel

```dart
// test/ui/categories/viewmodels/categories_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/repositories/categories/categories_repository.dart';
import 'package:mvvm/data/repositories/categories/categories_repository_dev.dart';
import 'package:mvvm/domain/use_cases/category_validation_use_case.dart';
import 'package:mvvm/ui/categories/viewmodels/categories_viewmodel.dart';

void main() {
  late CategoriesViewmodel categoriesViewmodel;
  late CategoriesRepository categoriesRepository;
  late CategoryValidationUseCase categoryValidationUseCase;

  setUp(() {
    categoriesRepository = CategoriesRepositoryDev();
    categoryValidationUseCase = CategoryValidationUseCase(
      categoriesRepository: categoriesRepository,
    );
    categoriesViewmodel = CategoriesViewmodel(
      categoriesRepository: categoriesRepository,
      categoryValidationUseCase: categoryValidationUseCase,
    );
  });

  group("CategoriesViewmodel Tests", () {
    test("Should load categories on initialization", () async {
      // Aguardar o load inicial
      await Future.delayed(const Duration(milliseconds: 500));
      
      expect(categoriesViewmodel.categories, isNotEmpty);
      expect(categoriesViewmodel.categories.length, equals(3));
    });

    test("Should add new category", () async {
      final initialCount = categoriesViewmodel.categories.length;

      await categoriesViewmodel.addCategory.execute((
        "Nova Categoria",
        "Descrição da nova categoria",
        "#FF9800",
      ));

      expect(categoriesViewmodel.categories.length, equals(initialCount + 1));
      expect(
        categoriesViewmodel.categories.last.name,
        equals("Nova Categoria"),
      );
    });

    test("Should filter categories by search query", () {
      categoriesViewmodel.setSearchQuery("trabalho");
      
      expect(categoriesViewmodel.filteredCategories.length, equals(1));
      expect(
        categoriesViewmodel.filteredCategories.first.name,
        equals("Trabalho"),
      );
    });

    test("Should clear search query", () {
      categoriesViewmodel.setSearchQuery("test");
      expect(categoriesViewmodel.searchQuery, equals("test"));
      
      categoriesViewmodel.clearSearch();
      expect(categoriesViewmodel.searchQuery, isEmpty);
    });
  });
}
```

#### 7.2 Teste do Use Case

```dart
// test/domain/use_cases/category_validation_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm/data/repositories/categories/categories_repository_dev.dart';
import 'package:mvvm/domain/models/category.dart';
import 'package:mvvm/domain/use_cases/category_validation_use_case.dart';
import 'package:mvvm/utils/result/result.dart';

void main() {
  late CategoryValidationUseCase useCase;
  late CategoriesRepositoryDev repository;

  setUp(() {
    repository = CategoriesRepositoryDev();
    useCase = CategoryValidationUseCase(categoriesRepository: repository);
  });

  group("CategoryValidationUseCase Tests", () {
    test("Should reject empty name", () async {
      const category = Category(
        id: "test",
        name: "",
        description: "Test",
        color: "#FF0000",
      );

      final result = await useCase.validateAndSave(category);
      
      expect(result, isA<Error>());
    });

    test("Should reject short name", () async {
      const category = Category(
        id: "test",
        name: "ab",
        description: "Test",
        color: "#FF0000",
      );

      final result = await useCase.validateAndSave(category);
      
      expect(result, isA<Error>());
    });

    test("Should reject invalid color", () async {
      const category = Category(
        id: "test",
        name: "Valid Name",
        description: "Test",
        color: "invalid-color",
      );

      final result = await useCase.validateAndSave(category);
      
      expect(result, isA<Error>());
    });

    test("Should accept valid category", () async {
      const category = Category(
        id: "test",
        name: "Valid Name",
        description: "Test description",
        color: "#FF0000",
      );

      final result = await useCase.validateAndSave(category);
      
      expect(result, isA<Ok>());
    });
  });
}
```

## 🎯 Checklist de Implementação

### ✅ Domain Layer
- [ ] Criar entidade/modelo
- [ ] Atualizar modelos existentes se necessário
- [ ] Criar use cases para regras de negócio
- [ ] Escrever testes para use cases

### ✅ Data Layer
- [ ] Criar interface do repository
- [ ] Implementar versão mock/dev
- [ ] Implementar versão remota (se necessário)
- [ ] Escrever testes para repositories

### ✅ UI Layer
- [ ] Criar ViewModel
- [ ] Implementar Commands necessários
- [ ] Criar widgets/screens
- [ ] Configurar navegação
- [ ] Escrever testes para ViewModel

### ✅ Configuration
- [ ] Atualizar dependencies.dart
- [ ] Adicionar rotas
- [ ] Configurar providers
- [ ] Atualizar documentação

### ✅ Testing
- [ ] Testes unitários para models
- [ ] Testes unitários para use cases
- [ ] Testes unitários para ViewModels
- [ ] Testes de integração (se necessário)

## 🔧 Comandos Úteis

### 🏃‍♂️ Executar Testes
```bash
# Todos os testes
flutter test

# Testes específicos
flutter test test/ui/categories/

# Testes com coverage
flutter test --coverage
```

### 🔨 Gerar Código (se usar Freezed/JsonSerializable)
```bash
# Gerar arquivos .g.dart e .freezed.dart
flutter packages pub run build_runner build

# Watch mode (regenera automaticamente)
flutter packages pub run build_runner watch
```

### 🧹 Analisar Código
```bash
# Análise estática
flutter analyze

# Formatação
flutter format lib/ test/
```

## 📚 Próximos Passos

1. **Implemente a funcionalidade completa**: Seguindo este guia
2. **Adicione testes abrangentes**: Para garantir qualidade
3. **Considere melhorias**: Cache, offline-first, etc.
4. **Documente**: Atualize a documentação conforme necessário

---

**Anterior:** [Padrões de Código](./04-padroes-codigo.md) | **Próximo:** [Testes](./06-testes.md)
