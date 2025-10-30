import 'package:flutter/material.dart';
import '../../dao/scripture_dao.dart';
import '../../models/scripture.dart';
import 'package:uuid/uuid.dart';

class ManageScriptureScreen extends StatefulWidget {
  const ManageScriptureScreen({super.key});

  @override
  State<ManageScriptureScreen> createState() => _ManageScriptureScreenState();
}

class _ManageScriptureScreenState extends State<ManageScriptureScreen> {
  final dao = ScriptureDao();
  List<Scripture> _scriptures = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await dao.getAll();
    setState(() {
      _scriptures = data;
    });
  }

  void _showEditDialog({Scripture? scripture}) {
    final titleController = TextEditingController(text: scripture?.title ?? '');
    final contentController =
        TextEditingController(text: scripture?.content ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(scripture == null ? 'Thêm bài đọc' : 'Chỉnh sửa bài đọc'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Nội dung'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Lưu'),
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              final newItem = Scripture(
                id: scripture?.id ?? const Uuid().v4(),
                title: titleController.text,
                content: contentController.text,
                isPublished: true,
              );

              if (scripture == null) {
                await dao.insert(newItem);
              } else {
                await dao.update(newItem);
              }

              Navigator.pop(context);
              _loadData();
            },
          ),
        ],
      ),
    );
  }

  void _deleteScripture(String id) async {
    await dao.delete(id);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý bài đọc'),
      ),
      body: _scriptures.isEmpty
          ? const Center(child: Text('Chưa có bài đọc nào'))
          : ListView.builder(
              itemCount: _scriptures.length,
              itemBuilder: (context, index) {
                final item = _scriptures[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(
                    item.content.length > 50
                        ? '${item.content.substring(0, 50)}...'
                        : item.content,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(scripture: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteScripture(item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
