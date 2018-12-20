import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_example/blocs/todo_bloc.dart';

class TodoProvider extends InheritedWidget {
  final TodoBloc bloc;

  TodoProvider({
    Key key,
    TodoBloc bloc,
    Widget child,
  })  : bloc = bloc ?? TodoBloc(),
        super(key: key, child: child);

@override
bool updateShouldNotify(InheritedWidget oldWidget) => true;

static TodoBloc of(BuildContext context) =>
  (context.inheritFromWidgetOfExactType(TodoProvider) as TodoProvider)
    .bloc;
}