import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/models/todo_item.dart';
import 'package:flutter_bloc_example/blocs/todo_bloc.dart';

class AddTodoScreen extends StatefulWidget {
  AddTodoScreen(this.onAddedNewTodo, this.todoBloc);

  final TodoBloc todoBloc;

  final VoidCallback onAddedNewTodo;
  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new todo"),
        actions: <Widget>[
          FlatButton(
            child: new Text("Save",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0
            ),),
            onPressed: () {
              _submitForm();
            },
          ),
        ],
      ),
      body: buildForm(),
    );
  }
  void _submitForm() {
    final FormState form = _formKey.currentState;

    if (!form.validate()) {
      print('Form is not valid!  Please review and correct.');
    } else {
      form.save();
      _saveTodoList(Todo("", _name, _description, false));
    }
  }

  void onAddedNewTodo(){
    if (widget.todoBloc != null) {
      //widget.todoBloc.getTodoList();
    }
    Navigator.of(context).pop();
    if (widget.onAddedNewTodo != null) {
      widget.onAddedNewTodo();
    }

  }

  void _saveTodoList(Todo todo){
    createNewTodo(todo, onAddedNewTodo);
  }

  void createNewTodo(Todo todo, Function onAddedNewTodo) {
    if (todo != null) {
      Firestore.instance.collection("todo").add(
        {"title": todo.name, "description": todo.description, "completed": todo.isDone}
      ).then(
          onAddedNewTodo()
      ).catchError((e) {
        print(this.runtimeType.toString() + ": " + e.toString());
      }
      );
    } else {
      print(this.runtimeType.toString() + ": error creating new todo");
    }
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new TextFormField(
                decoration: new InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                },
                onSaved: (String value) {
                  this._name = value;
                }),
            Container(height: 15.0,),
            new TextFormField(
                maxLines: 2,
                decoration: new InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                },
                onSaved: (String value) {
                  this._description = value;
                }),
          ],
        ),
      ),
    );
  }
}
