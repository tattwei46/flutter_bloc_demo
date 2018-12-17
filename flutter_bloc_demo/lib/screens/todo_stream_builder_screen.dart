import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/model/todo.dart';
import 'dart:async';

enum Result {
  FOUND,
  NOT_FOUND,
  NOT_DETERMINED,
}

class TodoStreamBuilder extends StatefulWidget {
  @override
  _TodoStreamBuilderState createState() => _TodoStreamBuilderState();
}

class _TodoStreamBuilderState extends State<TodoStreamBuilder> {
  List<Todo> _todoList = new List<Todo>();
  Result resultState = Result.NOT_DETERMINED;

  @override
  void initState() {
    _todoList.clear();
    resultState = Result.NOT_DETERMINED;

    super.initState();
  }

  Widget showResult(List<DocumentSnapshot> documents) {
    return TodoListView(documents: documents);
  }

  Widget showLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showNoResult() {
    return Center(
      child: new Text(
        "No Result",
        style: new TextStyle(fontSize: 30.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter BLOC Demo"),
      ),
      body: new StreamBuilder(
          stream: Firestore.instance.collection("todo").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return showResult(snapshot.data.documents);
              } else {
                return showNoResult();
              }
            } else return showLoading();
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
  final List<Todo> _todoList = new List<Todo>();

  TodoListView({this.documents});

  void updateTodo(Todo todo) {
    if (todo != null) {
      Firestore.instance
          .collection("todo")
          .document(todo.key)
          .updateData({
        'completed': !todo.isDone,
      }).then((onSaved){
        print("update success");
      }).catchError((e) {
        print(e.toString());
      });
    } else {
      print("documentId is null");
    }
  }

  @override
  Widget build(BuildContext context) {

    _todoList.addAll(
        documents.map((snapshot) => Todo.fromSnapshot(snapshot)));

    return ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: ((BuildContext context, int index){
        return ListTile(
          title: new Text(_todoList[index].title),
          subtitle: new Text(_todoList[index].description),
          trailing: _todoList[index].isDone
              ? Icon(Icons.done_outline, color: Colors.green)
              : Icon(Icons.done, color: Colors.grey),
          onTap: () {
            updateTodo(_todoList[index]);
          },
        );
      }),
    );
  }
}

