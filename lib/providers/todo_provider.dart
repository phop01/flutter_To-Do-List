import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoProvider with ChangeNotifier {
  List<TodoItem> _items = [];
  final String _prefKey = 'todos';

  TodoProvider() {
    loadTodos();
  }

  // เข้าถึงรายการทั้งหมด
  List<TodoItem> get allItems => _items;

  // กรองรายการที่ยังไม่เสร็จ (Pending)
  List<TodoItem> get pendingItems => _items.where((item) => !item.isDone).toList();

  // กรองรายการที่เสร็จแล้ว (Completed)
  List<TodoItem> get completedItems => _items.where((item) => item.isDone).toList();

  // บันทึกข้อมูลลงเครื่อง (Local Storage)
  Future<void> saveTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(_items.map((item) => item.toMap()).toList());
    await prefs.setString(_prefKey, encodedData);
  }

  // โหลดข้อมูลจากเครื่อง
  Future<void> loadTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_prefKey);
    if (encodedData != null) {
      final List<dynamic> decodedData = json.decode(encodedData);
      _items = decodedData.map((item) => TodoItem.fromMap(item)).toList();
      notifyListeners();
    }
  }

  // เพิ่มรายการใหม่ (Create)
  void addTodo(String title) {
    if (title.isEmpty) return;
    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _items.add(newItem);
    saveTodos();
    notifyListeners();
  }

  // แก้ไขรายการ (Update)
  void updateTodo(String id, String newTitle) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].title = newTitle;
      saveTodos();
      notifyListeners();
    }
  }

  // เปลี่ยนสถานะการเสร็จ (Update Status)
  void toggleTodoStatus(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index].isDone = !_items[index].isDone;
      saveTodos();
      notifyListeners();
    }
  }

  // ลบรายการ (Delete)
  void deleteTodo(String id) {
    _items.removeWhere((item) => item.id == id);
    saveTodos();
    notifyListeners();
  }
}
