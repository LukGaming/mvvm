import 'package:mvvm/data/services/api/models/todo/todo_api_model.dart';
import 'package:mvvm/domain/models/todo.dart';

const mockGetById = Todo(
  id: "1",
  name: "Primeiro",
  description: "Descrição",
  done: false,
);

const createTodoMock =
    CreateTodoApiModel(name: "Nome", description: "Descrição", done: false);

const addTodoMock = Todo(
  id: "1",
  name: "Nome",
  description: "Descrição",
  done: false,
);
