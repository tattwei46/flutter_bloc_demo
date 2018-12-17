import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String key;
  String title;
  String description;
  bool isDone;

  Todo(this.title, this.description, this.isDone);

  Todo.fromSnapshot(DocumentSnapshot snapshot)
      : key = snapshot.documentID,
        title = snapshot.data["title"],
        description = snapshot.data["description"],
        isDone = snapshot.data["completed"];
}