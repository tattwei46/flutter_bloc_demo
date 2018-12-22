import 'dart:async';

import 'package:flutter_bloc_example/models/todo_list.dart';
import 'package:flutter_bloc_example/models/todo_item.dart';
import 'package:rxdart/subjects.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoAddition {
  final String key;
  final String title;
  final String description;
  final bool isDone;

  TodoAddition(this.key, this.title, this.description, this.isDone);
}

class TodoRemoval {
  final int index;

  TodoRemoval(this.index);
}

class TodoBloc {
  final TodoList _todoList = TodoList();

  final BehaviorSubject<List<Todo>> _list =
      BehaviorSubject<List<Todo>>(seedValue: []);

  final BehaviorSubject<int> _listCount = BehaviorSubject<int>(seedValue: 0);

  final StreamController<TodoAddition> _todoAdditionController =
      StreamController<TodoAddition>();

  final StreamController<TodoRemoval> _todoRemovalController =
      StreamController<TodoRemoval>();

  TodoBloc() {
    _todoAdditionController.stream.listen((addition) {
      int currentCount = _todoList.getListCount;

      // Clear previous list before fetching
      //_todoList.clearList();

      for (int i =0; i < _todoList.getListCount; i++) {
        if (addition.key == _todoList.getList[i].key){
          return;
        }
      }

      //to generate new entry of Word class
      _todoList.addToList(Todo(
          addition.key, addition.title, addition.description, addition.isDone));
      _list.add(_todoList.getList);
      int updateCount = _todoList.getListCount;
      if (updateCount != currentCount) {
        _listCount.add(updateCount);
      }
    });

    _todoRemovalController.stream.listen((removal) {
      int currentCount = _todoList.getListCount;
      _todoList.removeAtIndex(removal.index);
      _list.add(_todoList.getList);
      int updateCount = _todoList.getListCount;
      if (updateCount != currentCount) {
        _listCount.add(updateCount);
      }
    });
  }

  void clearAll() {
    _todoList.clearList();
    _listCount.add(_todoList.getListCount);
    _list.add(_todoList.getList);
  }

  void removeAtIndex(int index) {
    _todoList.removeAtIndex(index);
  }

  int getIndexFromKey(String key) {
    for (int index = 0; index < _todoList.getListCount; index++) {
      if (key == _todoList.getTodoFromList(index).key) {
        return index;
      }
    }
  }

  void getTodoList() {
    //clearAll();
    final List<Todo> _todoList = new List<Todo>();

    _todoList.clear();

    Firestore.instance
        .collection("todo")
        .snapshots()
        .listen((QuerySnapshot event) {
      _todoList.clear();

      if (event.documents.length > 0) {
        _todoList.addAll(event.documents.map((snapshot) {
          //We have _todoList to force _todoAdditonalController.add to run. We do nothing with _todoList
          Todo todo = Todo.fromSnapshot(snapshot);
          _todoAdditionController.add(TodoAddition(
              snapshot.documentID, todo.name, todo.description, todo.isDone));
        }));
      }
    }).onError((handleError) {
      print("Error getting todo list");
    });
  }

  void updateTodo(Todo todo) {
    clearAll();
    if (todo != null) {
      Firestore.instance.collection("todo").document(todo.key).updateData({
        'completed': !todo.isDone,
      }).catchError((e) {
        print(e.toString());
      });
    } else {
      print("documentId is null");
    }
  }

  Sink<TodoAddition> get todoAdditionSink => _todoAdditionController.sink;

  Sink<TodoRemoval> get todoRemovalSink => _todoRemovalController.sink;

  Stream<int> get listCountStream => _listCount.stream;

  Stream<List<Todo>> get listStream => _list.stream;

  void dispose() {
    _list.close();
    _listCount.close();
    _todoAdditionController.close();
    _todoRemovalController.close();
  }
}
