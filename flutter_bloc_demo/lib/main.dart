import 'package:flutter/material.dart';
import 'screens/todo_setstate_screen.dart';
import 'screens/todo_stream_builder_screen.dart';
import 'screens/todo_bloc_screen.dart';
import 'bloc/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodoBloc(),
      ),
    );
  }
}

