import 'package:mvvm/data/services/api/models/todo/todo_api_model.dart';

void main() {
  const TodoApiModel todoApiModel = TodoApiModel.create(name: "Teste");

  print(todoApiModel.toJson());

  const todoCreate = CreateTodoApiModel(name: "Teste");

  print(todoCreate.toJson());

  const updateTodo = UpdateTodoApiModel(
    id: "teste",
    name: "Updated name",
  );

  print(updateTodo.toJson());
}
