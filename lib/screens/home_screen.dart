import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ค้างอยู่ (Pending)'),
              Tab(text: 'เสร็จแล้ว (Completed)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TodoList(filterType: 'pending'),
            TodoList(filterType: 'completed'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(context),
          tooltip: 'เพิ่มงานใหม่',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // แสดง Dialog สำหรับเพิ่มงานใหม่
  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มงานใหม่'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'ชื่อรายการงาน...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<TodoProvider>().addTodo(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final String filterType;

  const TodoList({super.key, required this.filterType});

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลจาก Provider ตามประเภทที่เลือก
    final provider = context.watch<TodoProvider>();
    final items = filterType == 'pending' ? provider.pendingItems : provider.completedItems;

    if (items.isEmpty) {
      return Center(
        child: Text(
          filterType == 'pending' ? 'ไม่มีงานที่ค้างอยู่' : 'ยังไม่มีงานที่เสร็จแล้ว',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final item = items[index];
        return TodoListItem(item: item);
      },
    );
  }
}

class TodoListItem extends StatelessWidget {
  final TodoItem item;

  const TodoListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: item.isDone,
          onChanged: (_) {
            context.read<TodoProvider>().toggleTodoStatus(item.id);
          },
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontSize: 18,
            // ขีดทับถ้างานเสร็จแล้ว
            decoration: item.isDone ? TextDecoration.lineThrough : null,
            color: item.isDone ? Colors.grey : Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ปุ่มแก้ไข
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditTodoDialog(context, item),
            ),
            // ปุ่มลบ
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                context.read<TodoProvider>().deleteTodo(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  // แสดง Dialog สำหรับแก้ไขงาน
  void _showEditTodoDialog(BuildContext context, TodoItem item) {
    final TextEditingController controller = TextEditingController(text: item.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขงาน'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'ชื่อรายการงานใหม่...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<TodoProvider>().updateTodo(item.id, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }
}
