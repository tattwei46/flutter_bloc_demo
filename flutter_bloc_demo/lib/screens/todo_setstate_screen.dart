import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/model/todo.dart';

enum Result {
  FOUND,
  NOT_FOUND,
  NOT_DETERMINED,
}

class TodoSetState extends StatefulWidget {
  @override
  _TodoSetStateState createState() => _TodoSetStateState();
}

class _TodoSetStateState extends State<TodoSetState> {
  List<Todo> _todoList = new List<Todo>();
  Result resultState = Result.NOT_DETERMINED;

  @override
  void initState() {
    _todoList.clear();
    resultState = Result.NOT_DETERMINED;

    getList();
    super.initState();
  }

  // Get list of todos and copy to local list
  void _onEntryAdded(QuerySnapshot event) {
    _todoList.clear();
    if (event.documents.length > 0) {
      _todoList.addAll(
          event.documents.map((snapshot) => Todo.fromSnapshot(snapshot)));
      setState(() {
        resultState = Result.FOUND;
      });
    } else {
      if (resultState == Result.NOT_DETERMINED) {
        setState(() {
          resultState = Result.NOT_FOUND;
        });
      }
    }
  }

  void getList() {
    getTodoList(_onEntryAdded);
  }

  // Send request to get list of todos from firestore
  void getTodoList(Function _onEntryAdded) {
    Firestore.instance
        .collection("todo")
        .snapshots()
        .listen(_onEntryAdded)
        .onError((handleError) {
      print("Error getting todo list");
    });
  }

  Widget showResult() {
    return new Center(
        child: new ListView.builder(
      itemCount: _todoList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(_todoList[index].title),
          subtitle: Text(_todoList[index].description),
          trailing: _todoList[index].isDone
              ? Icon(Icons.done_outline, color: Colors.green)
              : Icon(Icons.done, color: Colors.grey),
          onTap: () {
            updateTodo(_todoList[index], getList);
          },
        );
      },
    ));
  }

  Widget buildBody() {
    switch (resultState) {
      case Result.FOUND:
        return showResult();
        break;
      case Result.NOT_FOUND:
        return showNoResult();
        break;
      case Result.NOT_DETERMINED:
        return showLoading();
        break;
      default:
        return showNoResult();
        break;
    }
  }

  void updateTodo(Todo todo, Function onSuccess) {
    if (todo != null) {
      Firestore.instance.collection("todo").document(todo.key).updateData({
        'completed': !todo.isDone,
      }).then((onSaved) {
        onSuccess();
      }).catchError((e) {
        print(e.toString());
      });
    } else {
      print("documentId is null");
    }
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
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
