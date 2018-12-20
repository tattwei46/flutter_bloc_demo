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

class SetStateScreen extends StatefulWidget {
  @override
  _SetStateScreenState createState() => _SetStateScreenState();
}

class _SetStateScreenState extends State<SetStateScreen> {
  final TodoList _todoList = TodoList();
  Result resultState = Result.NOT_DETERMINED;

  @override
  void initState() {
    _todoList.clearList();
    getTodoList(_onEntryAdded);
    super.initState();
  }

  // Get list of todos and copy to list
  void _onEntryAdded(QuerySnapshot event) {
    _todoList.clearList();
    if (event.documents.length > 0) {
      _todoList.addAllToList(
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

  Widget buildBody() {
    switch (resultState) {
      case Result.FOUND:
        return showResult();
        break;
      case Result.NOT_FOUND:
        return CommonWidget().showNoResult();
        break;
      case Result.NOT_DETERMINED:
        return CommonWidget().showLoading();
        break;
      default:
        return CommonWidget().showNoResult();
        break;
    }
  }

  Widget showResult() {
    return new Center(
        child: new ListView.builder(
      itemCount: _todoList.getListCount,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(_todoList.getTodoFromList(index).name),
          subtitle: Text(_todoList.getTodoFromList(index).description),
          trailing: _todoList.getTodoFromList(index).isDone
              ? Icon(Icons.done_outline, color: Colors.green)
              : Icon(Icons.done, color: Colors.grey),
          onTap: () {
            updateTodo(_todoList.getTodoFromList(index), getList);
          },
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
