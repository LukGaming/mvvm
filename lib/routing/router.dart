import 'package:go_router/go_router.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_screen.dart';
import 'package:mvvm/ui/todo_details/viewmodels/todo_details_viewmodel.dart';
import 'package:mvvm/ui/todo_details/widgets/todo_details_screen.dart';
import 'package:provider/provider.dart';

GoRouter routerConfig() {
  return GoRouter(
    initialLocation: Routes.todos,
    routes: [
      GoRoute(
        path: Routes.todos,
        builder: (context, state) {
          return TodoScreen(
            todoViewmodel: TodoViewmodel(
              todosRepository: context.read(),
              todoUpdateUseCase: context.read(),
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
                todosRepository: context.read(),
                todoUpdateUseCase: context.read(),
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
