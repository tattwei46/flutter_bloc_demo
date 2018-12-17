import 'dart:async';
import 'package:flutter_bloc_example/model/todo.dart';

class Bloc {
  final _todo = StreamController<List<Todo>>();

  // Get data
  Stream<List<Todo>> get todoList => _todo.stream;

  // Add data
  Function(List<Todo>) get changeTodoList => _todo.sink.add;

  dispose(){
    _todo.close();
  }

}