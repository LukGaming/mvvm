import 'package:go_router/go_router.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_remote.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_screen.dart';
import 'package:mvvm/ui/todo_details/viewmodels/todo_details_viewmodel.dart';
import 'package:mvvm/ui/todo_details/widgets/todo_details_screen.dart';

GoRouter routerConfig() {
  final todosRepository = TodosRepositoryRemote(
    apiClient: ApiClient(
      host: "192.168.1.106",
    ),
  );

  final todoUpdateCase = TodoUpdateUseCase(todosRepository: todosRepository);

  return GoRouter(
    initialLocation: Routes.todos,
    routes: [
      GoRoute(
        path: Routes.todos,
        builder: (context, state) {
          return TodoScreen(
            todoViewmodel: TodoViewmodel(
              todosRepository: todosRepository,
              todoUpdateUseCase: todoUpdateCase,
            ),
          );
        },
        routes: [
          GoRoute(
            path: ":id",
            builder: (context, state) {
              final todoId = state.pathParameters["id"]!;
              final TodoDetailsViewModel todoDetailsViewModel =
                  TodoDetailsViewModel(
                todosRepository: todosRepository,
                todoUpdateUseCase: todoUpdateCase,
              );

              todoDetailsViewModel.load.execute(todoId);

              return TodoDetailsScreen(
                todoDetailsViewModel: todoDetailsViewModel,
              );
            },
          ),
        ],
      ),
    ],
  );
}
