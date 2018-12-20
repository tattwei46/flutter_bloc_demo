import 'package:flutter/material.dart';
import 'package:flutter_bloc_example/models/todo_item.dart';
import 'package:flutter_bloc_example/blocs/todo_provider.dart';
import 'package:flutter_bloc_example/blocs/todo_bloc.dart';
import 'package:flutter_bloc_example/common_widgets/common_widgets.dart';

class BlocScreen extends StatelessWidget {
  BlocScreen();

  @override
  Widget build(BuildContext context) {
    final todoBloc = TodoProvider.of(context);

    // get data
    todoBloc.getTodoList();

    return Scaffold(
        body: StreamBuilder<List<Todo>>(
          stream: todoBloc.listStream,
          builder: (context, snapshot) {

            // No Result
            if (snapshot.data == null || snapshot.data.isEmpty) {
              return CommonWidget().showNoResult();
            } else if (snapshot.data.length > 0) {

              // Result
              final tiles = snapshot.data.map((item) {
                return new ListTile(
                  title: new Text(item.name),
                  subtitle: (new Text(item.description)),
                  trailing: item.isDone
                      ? Icon(Icons.done_outline, color: Colors.green)
                      : Icon(Icons.done, color: Colors.grey),
                  onTap: () {
                    todoBloc.updateTodo(item);
                  },
                );
              });

              final divided = ListTile.divideTiles(
                context: context,
                tiles: tiles,
              ).toList();

              return new ListView(children: divided);
            } else {
              // Still loadingn
              return CommonWidget().showLoading();
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            todoBloc.todoAdditionSink
                .add(TodoAddition("A", "test", "description", false));
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}
