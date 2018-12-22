import 'package:flutter/material.dart';
import 'screens/set_state_screen.dart';
import 'screens/stream_builder_screen.dart';
import 'screens/bloc_screen.dart';
import 'package:flutter_bloc_example/blocs/todo_bloc.dart';
import 'package:flutter_bloc_example/blocs/todo_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootScreen(),

    );
  }
}

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {

  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _children = [
    SetStateScreen(),
    StreamBuilderScreen(),
    TodoProvider(
      child: BlocScreen(),
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.refresh),
            title: new Text("SetState"),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.compare_arrows),
            title: new Text("Streambuilder"),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.border_all),
              title: Text("Bloc"),
          )
        ],
        onTap: onTabTapped,
      ),
    );
  }
}


