import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/models/todo_item.dart';
import 'package:flutter_bloc_example/models/todo_list.dart';
import 'package:flutter_bloc_example/common_widgets/common_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new StreamBuilder(
          stream: Firestore.instance.collection("todo").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return showResult(snapshot.data.documents);
              } else {
                return CommonWidget().showNoResult();
              }
            } else return CommonWidget().showLoading();
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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

  void updateTodo(Todo todo) {
    if (todo != null) {
      Firestore.instance
          .collection("todo")
          .document(todo.key)
          .updateData({
        'completed': !todo.isDone,
      }).then((onSaved){
        print(this.runtimeType.toString() + ": update success");
      }).catchError((e) {
        print(this.runtimeType.toString() + ": "+ e.toString());
      });
    } else {
      print(this.runtimeType.toString() + ": documentId is null");
    }
  }

  @override
  Widget build(BuildContext context) {

    _todoList.addAllToList(
        documents.map((snapshot) => Todo.fromSnapshot(snapshot)));

    return ListView.builder(
      itemCount: _todoList.getListCount,
      itemBuilder: ((BuildContext context, int index){
        return ListTile(
          title: new Text(_todoList.getTodoFromList(index).name),
          subtitle: new Text(_todoList.getTodoFromList(index).description),
          trailing: _todoList.getTodoFromList(index).isDone
              ? Icon(Icons.done_outline, color: Colors.green)
              : Icon(Icons.done, color: Colors.grey),
          onTap: () {
            updateTodo(_todoList.getTodoFromList(index));
          },
        );
      }),
    );
  }
}

