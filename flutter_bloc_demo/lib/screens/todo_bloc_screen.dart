import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/model/todo.dart';
import 'dart:async';
import 'package:flutter_bloc_example/bloc/provider.dart';
import 'package:flutter_bloc_example/bloc/bloc.dart';

enum Result {
  FOUND,
  NOT_FOUND,
  NOT_DETERMINED,
}

class TodoBloc extends StatefulWidget {
  @override
  _TodoBlocState createState() => _TodoBlocState();
}

class _TodoBlocState extends State<TodoBloc> {
  List<Todo> _todoList = new List<Todo>();
  Result resultState = Result.NOT_DETERMINED;
  Bloc bloc = new Bloc();

  @override
  void initState() {
    _todoList.clear();
    resultState = Result.NOT_DETERMINED;
    getList(bloc);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = Provider.of(context);
  }

  void getList(Bloc bloc) {
    getTodoList(_onEntryAdded, bloc);
  }

  // Send request to get list of todos from firestore
  void getTodoList(Function _onEntryAdded, Bloc bloc) {
    Firestore.instance
        .collection("todo")
        .snapshots()
        .listen(_onEntryAdded)
        .onError((handleError) {
      print("Error getting todo list");
    });
  }

  // Get list of todos and copy to local list
  void _onEntryAdded(QuerySnapshot event) {
    _todoList.clear();
    if (event.documents.length > 0) {
      _todoList.addAll(
          event.documents.map((snapshot) => Todo.fromSnapshot(snapshot)));
      bloc.changeTodoList(_todoList);
//      setState(() {
//        resultState = Result.FOUND;
//      });
    } else {
      if (resultState == Result.NOT_DETERMINED) {
//        setState(() {
//          resultState = Result.NOT_FOUND;
//        });
      }
    }
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
          stream: bloc.todoList,
          builder: (BuildContext context, snapshot){
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

