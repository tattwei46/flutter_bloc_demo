import 'package:flutter_bloc_example/models/todo_item.dart';
import 'dart:collection';


class TodoList {
  final List<Todo> _todoList = <Todo>[];

  TodoList();

  int get getListCount => _todoList.length;

  UnmodifiableListView<Todo> get getList => UnmodifiableListView(_todoList);

//  void addToList (String key, String name, String description, bool isDone) {
//    _todoList.add(Todo(key, name, description, isDone));
//  }

  void addToList (Todo todo) {
    _todoList.add(todo);
  }

  void addAllToList (Iterable<Todo> todo) {
    _todoList.addAll(todo);
  }

  void removeFromList (String name) {
    _updateCountRemove(name);
  }

  void clearList() {
    _todoList.clear();
  }

  Todo getTodoFromList(int index){
    return _todoList[index];
  }

//  @override
//  String toString() => "$getTodoList";

  void _updateCountRemove(String name) {
    for (int i = 0; i < _todoList.length; i++) {
      final item = _todoList[i];
      if (name == item.name) {
         _todoList.removeAt(i);
      }
    }
  }
}