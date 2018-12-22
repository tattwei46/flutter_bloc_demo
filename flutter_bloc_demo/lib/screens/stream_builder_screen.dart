import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/models/todo_item.dart';
import 'package:flutter_bloc_example/models/todo_list.dart';
import 'package:flutter_bloc_example/common_widgets/common_widgets.dart';
import 'package:flutter_bloc_example/screens/add_todo_screen.dart';
import 'package:flutter_bloc_example/common_functions/common_functions.dart';

enum Result {
  FOUND,
  NOT_FOUND,
  NOT_DETERMINED,
}

class StreamBuilderScreen extends StatefulWidget {
  @override
  _StreamBuilderScreenState createState() => _StreamBuilderScreenState();
}

class _StreamBuilderScreenState extends State<StreamBuilderScreen> {
  Result resultState = Result.NOT_DETERMINED;

  @override
  void initState() {
    super.initState();
  }

  Widget showResult(List<DocumentSnapshot> documents) {
    return TodoListView(documents: documents);
  }

  void onNewTodoAdded() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Bloc Demo"),
      ),
      body: new StreamBuilder(
          stream: Firestore.instance.collection("todo").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return showResult(snapshot.data.documents);
              } else {
                return CommonWidget().showNoResult();
              }
            } else
              return CommonWidget().showLoading();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) =>
                  AddTodoScreen(onNewTodoAdded, null)));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class TodoListView extends StatelessWidget {
  final List<DocumentSnapshot> documents;
  final TodoList _todoList = new TodoList();


  TodoListView({this.documents});

  void deleteTodo(String documentId) {
    Firestore.instance
        .collection("todo")
        .document(documentId)
        .delete()
        .then((onValue) {
    }).catchError((e) {
      print(e);
    });
  }

  void updateTodo(Todo todo) {
    if (todo != null) {
      Firestore.instance.collection("todo").document(todo.key).updateData({
        'completed': !todo.isDone,
      }).then((onSaved) {
        print(this.runtimeType.toString() + ": update success");
      }).catchError((e) {
        print(this.runtimeType.toString() + ": " + e.toString());
      });
    } else {
      print(this.runtimeType.toString() + ": documentId is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    FunctionStatus functionStatus = FunctionStatus.UNKNOWN;

    _todoList
        .addAllToList(documents.map((snapshot) => Todo.fromSnapshot(snapshot)));

    return ListView.builder(
      itemCount: _todoList.getListCount,
      itemBuilder: ((BuildContext context, int index) {
        return Dismissible (
          key: Key(_todoList.getTodoFromList(index).key),
          background: Container(color: Colors.red),
          onDismissed: (direction) async {
            functionStatus = CommonFunctions.deleteTodo(
                _todoList.getTodoFromList(index).key, null);
            if (functionStatus == FunctionStatus.DONE) {
              _todoList.removeAtIndex(index);
            }
          },
          child: ListTile(
            title: new Text(_todoList.getTodoFromList(index).name),
            subtitle: new Text(_todoList.getTodoFromList(index).description),
            trailing: _todoList.getTodoFromList(index).isDone
                ? Icon(Icons.done_outline, color: Colors.green)
                : Icon(Icons.done, color: Colors.grey),
            onTap: () {
              updateTodo(_todoList.getTodoFromList(index));
            },
          ),
        );
      }),
    );
  }
}
