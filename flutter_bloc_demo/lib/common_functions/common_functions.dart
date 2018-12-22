import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc_example/blocs/todo_bloc.dart';

enum FunctionStatus {
  DONE,
  NOT_DONE,
  UNKNOWN,
}

class CommonFunctions {
  static FunctionStatus deleteTodo(String documentId, Function onSuccessDeleted) {
    Firestore.instance
        .collection("todo")
        .document(documentId)
        .delete()
        .then((onValue){
          onSuccessDeleted();
          return FunctionStatus.DONE;
        })
        .catchError((e) {
      print(e);
      return FunctionStatus.NOT_DONE;
    });
    return FunctionStatus.UNKNOWN;
  }
}