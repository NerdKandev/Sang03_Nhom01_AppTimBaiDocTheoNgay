import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../dao/author_dao.dart';
import '../../models/author.dart';

class ManageAuthorScreen extends StatefulWidget {
  const ManageAuthorScreen({super.key});

  @override
  State<ManageAuthorScreen> createState() => _ManageAuthorScreenState();
}

class _ManageAuthorScreenState extends State<ManageAuthorScreen> {
  final dao = AuthorDao();
  final uuid = const Uuid();
  List<Author> _authors = [];

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    final data = await dao.getAll();
    setState(() => _authors = data);
  }

  void _openForm({Author? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final bioController = TextEditingController(text: item?.bio ?? '');
    final avatarController = TextEditingController(text: item?.avatarUrl ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Thêm Tác giả' : 'Chỉnh sửa Tác giả'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên tác giả')),
              TextField(controller: bioController, decoration: const InputDecoration(labelText: 'Tiểu sử')),
              TextField(controller: avatarController, decoration: const InputDecoration(labelText: 'Ảnh đại diện (URL)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newItem = Author(
                id: item?.id ?? uuid.v4(),
                name: nameController.text,
                bio: bioController.text,
                avatarUrl: avatarController.text,
              );
              if (item == null) await dao.insert(newItem);
              else await dao.update(newItem);
              if (mounted) Navigator.pop(context);
              _loadAuthors();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    await dao.delete(id);
    _loadAuthors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Tác giả')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _authors.length,
        itemBuilder: (_, i) {
          final a = _authors[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: a.avatarUrl != null && a.avatarUrl!.isNotEmpty
                  ? NetworkImage(a.avatarUrl!)
                  : null,
              child: a.avatarUrl == null || a.avatarUrl!.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(a.name),
            subtitle: Text(
              a.bio ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () => _openForm(item: a), icon: const Icon(Icons.edit)),
                IconButton(onPressed: () => _delete(a.id), icon: const Icon(Icons.delete, color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
