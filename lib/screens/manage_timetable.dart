import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../dao/timetable_dao.dart';
import '../../models/timetable.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  final dao = TimetableDao();
  final uuid = const Uuid();
  List<Timetable> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    final data = await dao.getAll();
    setState(() => _schedules = data);
  }

  void _openForm({Timetable? item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final hourController = TextEditingController(text: item?.hour?.toString() ?? '');
    final minuteController = TextEditingController(text: item?.minute?.toString() ?? '');
    bool repeatDaily = item?.repeatDaily == 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Thêm Lịch tụng' : 'Chỉnh sửa Lịch tụng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên lịch tụng'),
              ),
              TextField(
                controller: hourController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giờ (0-23)'),
              ),
              TextField(
                controller: minuteController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Phút (0-59)'),
              ),
              // ✅ Dùng StatefulBuilder để cập nhật đúng biến bool trong dialog
              StatefulBuilder(
                builder: (context, setInnerState) {
                  return SwitchListTile(
                    value: repeatDaily,
                    onChanged: (val) => setInnerState(() => repeatDaily = val),
                    title: const Text('Lặp lại hàng ngày'),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newItem = Timetable(
                id: item?.id ?? uuid.v4(),
                name: nameController.text.trim(),
                hour: int.tryParse(hourController.text) ?? 0,
                minute: int.tryParse(minuteController.text) ?? 0,
                scriptureId: item?.scriptureId,
                repeatDaily: repeatDaily ? true : false, // ✅ bool → int để lưu DB
              );

              if (item == null) {
                await dao.insert(newItem);
              } else {
                await dao.update(newItem);
              }

              if (mounted) Navigator.pop(context);
              _loadSchedules();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    await dao.delete(id);
    _loadSchedules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Lịch tụng')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _schedules.length,
        itemBuilder: (_, i) {
          final s = _schedules[i];
          return ListTile(
            title: Text(s.name),
            subtitle: Text(
              '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}  •  ${s.repeatDaily == 1 ? "Lặp hằng ngày" : "Một lần"}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _openForm(item: s),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _delete(s.id),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
