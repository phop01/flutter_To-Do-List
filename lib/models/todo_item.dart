import 'dart:convert';

class TodoItem {
  final String id;
  String title;
  bool isDone;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  // แปลงข้อมูลเป็น Map เพื่อเก็บใน Local Storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  // สร้าง TodoItem จาก Map ที่อ่านจาก Local Storage
  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }

  // แปลงข้อมูลเป็น JSON String
  String toJson() => json.encode(toMap());

  // สร้าง TodoItem จาก JSON String
  factory TodoItem.fromJson(String source) => TodoItem.fromMap(json.decode(source));
}
