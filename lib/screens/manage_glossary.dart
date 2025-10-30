import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../dao/glossary_item_dao.dart';
import '../../models/glossary_item.dart';

class ManageGlossaryScreen extends StatefulWidget {
  const ManageGlossaryScreen({super.key});

  @override
  State<ManageGlossaryScreen> createState() => _ManageGlossaryScreenState();
}

class _ManageGlossaryScreenState extends State<ManageGlossaryScreen> {
  final dao = GlossaryItemDao();
  final uuid = const Uuid();
  List<GlossaryItem> _items = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await dao.getAll();
    setState(() => _items = data);
  }

  void _openForm({GlossaryItem? item}) {
    final termController = TextEditingController(text: item?.term ?? '');
    final definitionController = TextEditingController(text: item?.definition ?? '');
    final synonymsController = TextEditingController(text: item?.synonyms ?? '');
    final tagsController = TextEditingController(text: item?.tags ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Thêm thuật ngữ' : 'Chỉnh sửa thuật ngữ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: termController, decoration: const InputDecoration(labelText: 'Thuật ngữ')),
              TextField(controller: definitionController, decoration: const InputDecoration(labelText: 'Định nghĩa')),
              TextField(controller: synonymsController, decoration: const InputDecoration(labelText: 'Từ đồng nghĩa')),
              TextField(controller: tagsController, decoration: const InputDecoration(labelText: 'Tags')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newItem = GlossaryItem(
                id: item?.id ?? uuid.v4(),
                term: termController.text,
                definition: definitionController.text,
                synonyms: synonymsController.text,
                tags: tagsController.text,
              );
              if (item == null) {
                await dao.insert(newItem);
              } else {
                await dao.update(newItem);
              }
              if (mounted) Navigator.pop(context);
              _loadItems();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    await dao.delete(id);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((g) {
      final q = _searchQuery.toLowerCase();
      return g.term.toLowerCase().contains(q) ||
          (g.definition?.toLowerCase().contains(q) ?? false) ||
          (g.synonyms?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Từ điển Phật pháp'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final g = filtered[i];
          return ListTile(
            title: Text(g.term),
            subtitle: Text(
              g.definition ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () => _openForm(item: g), icon: const Icon(Icons.edit)),
                IconButton(onPressed: () => _delete(g.id), icon: const Icon(Icons.delete, color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
