import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../dao/category_dao.dart';
import '../../models/category.dart';

class ManageCategoryScreen extends StatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  State<ManageCategoryScreen> createState() => _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends State<ManageCategoryScreen> {
  final dao = CategoryDao();
  final uuid = const Uuid();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await dao.getAll();
    setState(() => _categories = data);
  }

  void _openForm({Category? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Thêm Danh mục' : 'Chỉnh sửa Danh mục'),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên danh mục')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newItem = Category(id: item?.id ?? uuid.v4(), name: nameController.text);
              if (item == null) await dao.insert(newItem);
              else await dao.update(newItem);
              if (mounted) Navigator.pop(context);
              _loadCategories();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    await dao.delete(id);
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Danh mục')),
      floatingActionButton: FloatingActionButton(onPressed: () => _openForm(), child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final c = _categories[i];
          return ListTile(
            title: Text(c.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () => _openForm(item: c), icon: const Icon(Icons.edit)),
                IconButton(onPressed: () => _delete(c.id), icon: const Icon(Icons.delete, color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
