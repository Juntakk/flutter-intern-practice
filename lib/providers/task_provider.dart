import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_manager/main.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<QueryDocumentSnapshot> _tasks = [];
  bool isLoading = false;

  List<QueryDocumentSnapshot> get tasks => _tasks;

  Future<void> fetchTasks() async {
    isLoading = true;

    final User? user = _auth.currentUser;
    if (user != null) {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: user.uid)
          .get();
      _tasks = querySnapshot.docs;
      notifyListeners();
      isLoading = false;
    }
  }

  Future<void> addTask(Map<String, dynamic> taskData) async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final newTaskRef = await _firestore.collection('tasks').add({
        ...taskData,
        'userId': user.uid,
      });
      await fetchTasks();
    }
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> taskData) async {
    await _firestore.collection('tasks').doc(taskId).update(taskData);
    await fetchTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
    await fetchTasks();
  }
}
