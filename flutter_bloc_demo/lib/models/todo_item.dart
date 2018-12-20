import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String key;
  final String name;
  final String description;
  final bool isDone;

  Todo(this.key, this.name, this.description, this.isDone);

  Todo.fromSnapshot(DocumentSnapshot snapshot)
      : key = snapshot.documentID,
        name = snapshot.data["title"],
        description = snapshot.data["description"],
        isDone = snapshot.data["completed"];
}
