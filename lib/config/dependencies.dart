import 'package:mvvm/data/repositories/todos/todos_repository.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_dev.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_remote.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersRemote {
  return [
    Provider(
      create: (context) => ApiClient(
        host: "192.168.1.106",
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

List<SingleChildWidget> get providersLocal {
  return [
    ChangeNotifierProvider(
      create: (context) => TodosRepositoryDev() as TodosRepository,
    ),
    ..._sharedProviders
  ];
}

List<SingleChildWidget> get _sharedProviders {
  return [
    Provider(
      create: (context) => TodoUpdateUseCase(
        todosRepository: context.read(),
      ),
    )
  ];
}
