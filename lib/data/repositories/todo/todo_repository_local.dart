import 'package:mvvm/core/result/result.dart';
import 'package:mvvm/data/repositories/todo/todo_repository.dart';
import 'package:mvvm/domain/models/todo.dart';

class TodoRepositoryLocal extends TodoRepository {
  final List<Todo> _todos = [];
  @override
  Future<Result<Todo>> add(String name) async {
    final lastTodoIndex = _todos.length;
    final Todo createdTodo = Todo(id: lastTodoIndex + 1, name: name);
    _todos.add(createdTodo);
    return Result.ok(createdTodo);
  }

  @override
  Future<Result<void>> delete(Todo todo) async {
    _todos.remove(todo);
    return Result.ok(null);
  }

  @override
  Future<Result<List<Todo>>> get() async {
    return Result.ok(_todos);
  }
}
