import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../dao/audio_item_dao.dart'; // <-- import đúng file DAO
import '../../models/audio_item.dart';

class ManageAudioScreen extends StatefulWidget {
  const ManageAudioScreen({super.key});

  @override
  State<ManageAudioScreen> createState() => _ManageAudioScreenState();
}

class _ManageAudioScreenState extends State<ManageAudioScreen> {
  final dao = AudioItemDao(); // <-- dùng đúng tên lớp
  final uuid = const Uuid();
  List<AudioItem> _audios = [];

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  Future<void> _loadAudios() async {
    final data = await dao.getAll();
    setState(() => _audios = data);
  }

  void _openForm({AudioItem? item}) {
    final titleController = TextEditingController(text: item?.title ?? '');
    final pathController = TextEditingController(text: item?.path ?? '');
    final durationController = TextEditingController(
      text: item?.duration != null ? item!.duration.toString() : '',
    );
    final narratorController = TextEditingController(text: item?.narrator ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Thêm Bài nghe' : 'Chỉnh sửa Bài nghe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Tiêu đề')),
              TextField(controller: pathController, decoration: const InputDecoration(labelText: 'Đường dẫn file')),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Thời lượng (giây)'),
                keyboardType: TextInputType.number,
              ),
              TextField(controller: narratorController, decoration: const InputDecoration(labelText: 'Người đọc')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              final newItem = AudioItem(
                id: item?.id ?? uuid.v4(),
                title: titleController.text,
                path: pathController.text,
                duration: int.tryParse(durationController.text) ?? 0,
                narrator: narratorController.text,
                scriptureId: item?.scriptureId,
              );
              if (item == null) {
                await dao.insert(newItem);
              } else {
                await dao.update(newItem);
              }
              if (mounted) Navigator.pop(context);
              _loadAudios();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    await dao.delete(id);
    _loadAudios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Bài nghe')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _audios.length,
        itemBuilder: (_, i) {
          final a = _audios[i];
          return ListTile(
            title: Text(a.title),
            subtitle: Text(
              '${a.narrator ?? "Không rõ"} • ${a.duration ?? 0} giây',
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
