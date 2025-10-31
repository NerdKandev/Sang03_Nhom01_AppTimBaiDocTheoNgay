import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../services/data_service.dart';
import '../services/category_service.dart';
import '../services/reminder_service.dart';
import '../models/sutra.dart';
import '../models/reminder_model.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final DataService _dataService = DataService();
  final CategoryService _categoryService = CategoryService();
  final ReminderService _reminderService = ReminderService();
  
  int _currentStep = 0;
  
  // Step 1: Time selection
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeOfDay; // 'morning', 'afternoon', 'evening', 'night'
  
  // Step 2: Category selection
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  
  // Step 3: Sutra selection
  List<String> _selectedSutraIds = [];
  
  @override
  void initState() {
    super.initState();
    _categoryService.initializeCategories();
    _dataService.initializeData();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    await _reminderService.initializeReminders();
    if (mounted) {
      setState(() {});
    }
  }

  List<Sutra> get _availableSutras {
    if (_selectedCategoryId == null || _selectedCategoryName == null) {
      return [];
    }
    return _dataService.sutras
        .where((sutra) => sutra.category == _selectedCategoryName)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Đặt lịch nhắc đọc kinh'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showFileInfo,
            tooltip: 'Thông tin file dữ liệu',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stepper section
          Expanded(
            child: Stepper(
              currentStep: _currentStep,
              onStepContinue: _currentStep < 2 ? _continueToNextStep : _confirmReminder,
              onStepCancel: _cancelStep,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Quay lại'),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _currentStep < 2 ? 'Tiếp theo' : 'Xác nhận đặt lịch',
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                // Step 1: Time selection
                Step(
                  title: const Text('Chọn thời gian'),
                  subtitle: const Text('Chọn ngày, giờ và buổi trong ngày'),
                  content: _buildTimeSelectionStep(),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : (_currentStep == 0 ? StepState.indexed : StepState.disabled),
                ),
                
                // Step 2: Category selection
                Step(
                  title: const Text('Chọn danh mục'),
                  subtitle: Text(_selectedCategoryName ?? 'Chọn danh mục kinh muốn đọc'),
                  content: _buildCategorySelectionStep(),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : (_currentStep == 1 ? StepState.indexed : StepState.disabled),
                ),
                
                // Step 3: Sutra selection
                Step(
                  title: const Text('Chọn bài đọc'),
                  subtitle: Text(_selectedSutraIds.isEmpty
                      ? 'Chọn các bài kinh muốn đọc'
                      : 'Đã chọn ${_selectedSutraIds.length} bài'),
                  content: _buildSutraSelectionStep(),
                  isActive: _currentStep >= 2,
                  state: _currentStep == 2 ? StepState.indexed : StepState.disabled,
                ),
              ],
            ),
          ),
          
          // List of saved reminders
          _buildRemindersList(),
        ],
      ),
    );
  }

  Widget _buildTimeSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date selection
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF2196F3)),
            title: const Text('Ngày đọc'),
            subtitle: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Time selection
        Card(
          child: ListTile(
            leading: const Icon(Icons.access_time, color: Color(0xFF2196F3)),
            title: const Text('Giờ đọc'),
            subtitle: Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null && picked != _selectedTime) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Time of day selection
        const Text(
          'Buổi trong ngày:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTimeOfDayChip('Sáng', 'morning', Icons.wb_sunny),
            _buildTimeOfDayChip('Trưa', 'afternoon', Icons.wb_twilight),
            _buildTimeOfDayChip('Chiều', 'evening', Icons.wb_cloudy),
            _buildTimeOfDayChip('Tối', 'night', Icons.nightlight),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeOfDayChip(String label, String value, IconData icon) {
    final isSelected = _selectedTimeOfDay == value;
    return FilterChip(
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey),
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTimeOfDay = selected ? value : null;
        });
      },
      selectedColor: const Color(0xFF2196F3),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCategorySelectionStep() {
    final categories = _categoryService.getActiveCategories();
    
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.category, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Chưa có danh mục nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn một danh mục:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) {
          // Calculate actual sutra count from DataService instead of using category.sutraCount
          final actualCount = _dataService.sutras.where((sutra) => sutra.category == category.name).length;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: RadioListTile<String>(
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(category.description),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _parseColor(category.color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$actualCount bài đọc',
                          style: TextStyle(
                            fontSize: 11,
                            color: _parseColor(category.color),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              value: category.id,
              groupValue: _selectedCategoryId,
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                  _selectedCategoryName = category.name;
                  _selectedSutraIds.clear(); // Reset sutra selection when category changes
                });
              },
              activeColor: _parseColor(category.color),
              secondary: CircleAvatar(
                backgroundColor: _parseColor(category.color).withOpacity(0.2),
                child: Icon(
                  _getIconData(category.icon),
                  color: _parseColor(category.color),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSutraSelectionStep() {
    if (_selectedCategoryId == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Vui lòng chọn danh mục trước',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    
    final sutras = _availableSutras;
    
    if (sutras.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.library_books, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Danh mục "${_selectedCategoryName}" chưa có bài đọc nào',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chọn bài đọc (đã chọn: ${_selectedSutraIds.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_selectedSutraIds.length < sutras.length)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedSutraIds = sutras.map((s) => s.id).toList();
                  });
                },
                icon: const Icon(Icons.select_all, size: 18),
                label: const Text('Chọn tất cả'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView.builder(
            itemCount: sutras.length,
            itemBuilder: (context, index) {
              final sutra = sutras[index];
              final isSelected = _selectedSutraIds.contains(sutra.id);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : null,
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedSutraIds.add(sutra.id);
                      } else {
                        _selectedSutraIds.remove(sutra.id);
                      }
                    });
                  },
                  title: Text(
                    sutra.titleVietnamese,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF2196F3) : null,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        sutra.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sutra.isFavorite ? Colors.red[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sutra.isFavorite ? 'Yêu thích bài đọc' : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: sutra.isFavorite ? Colors.red[800] : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${sutra.readingTime}',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  secondary: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? const Color(0xFF2196F3) : Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _continueToNextStep() {
    if (_currentStep == 0) {
      // Validate time selection
      if (_selectedTimeOfDay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn buổi trong ngày'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      // Validate category selection
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn một danh mục'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }
    
    setState(() {
      _currentStep++;
    });
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _confirmReminder() {
    // Validate sutra selection
    if (_selectedSutraIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một bài đọc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Xác nhận đặt lịch'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow(Icons.calendar_today, 'Ngày', 
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            _buildConfirmRow(Icons.access_time, 'Giờ', 
              _selectedTime.format(context)),
            _buildConfirmRow(Icons.wb_sunny, 'Buổi', 
              _getTimeOfDayLabel(_selectedTimeOfDay!)),
            _buildConfirmRow(Icons.category, 'Danh mục', 
              _selectedCategoryName ?? ''),
            _buildConfirmRow(Icons.library_books, 'Số bài đọc', 
              '${_selectedSutraIds.length} bài'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveReminder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _saveReminder() async {
    try {
      // Get sutra titles
      final selectedSutras = _dataService.sutras
          .where((sutra) => _selectedSutraIds.contains(sutra.id))
          .toList();
      final sutraTitles = selectedSutras.map((s) => s.titleVietnamese).toList();

      // Create reminder
      final reminder = ReminderModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        time: _selectedTime,
        timeOfDay: _selectedTimeOfDay!,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName!,
        sutraIds: _selectedSutraIds,
        sutraTitles: sutraTitles,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Save reminder
      await _reminderService.addReminder(reminder);

      if (mounted) {
        // Refresh reminders list
        await _loadReminders();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Đã đặt lịch nhắc đọc kinh thành công!'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Reset form
        setState(() {
          _currentStep = 0;
          _selectedTimeOfDay = null;
          _selectedCategoryId = null;
          _selectedCategoryName = null;
          _selectedSutraIds.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu lịch nhắc: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Widget _buildRemindersList() {
    final reminders = _reminderService.reminders;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (reminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[50],
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none, size: 32, color: Colors.grey[isDark ? 500 : 400]),
            const SizedBox(height: 8),
            Text(
              'Chưa có lịch nhắc nào',
              style: TextStyle(
                color: Colors.grey[isDark ? 400 : 600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Color(0xFF2196F3), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Lịch nhắc đã đặt (${reminders.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: reminders.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(ReminderModel reminder) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 1,
      color: isDark ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTimeOfDayIcon(reminder.timeOfDay),
                  color: const Color(0xFF2196F3),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${_getTimeOfDayLabel(reminder.timeOfDay)} • ${reminder.date.day}/${reminder.date.month}/${reminder.date.year} • ${reminder.time.hour.toString().padLeft(2, '0')}:${reminder.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red[isDark ? 300 : 700],
                  ),
                  onPressed: () => _deleteReminder(reminder.id),
                  tooltip: 'Xóa lịch nhắc',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 14,
                  color: Colors.grey[isDark ? 400 : 600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reminder.categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.library_books,
                  size: 14,
                  color: Colors.grey[isDark ? 400 : 600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${reminder.sutraTitles.length} bài: ${reminder.sutraTitles.take(2).join(', ')}${reminder.sutraTitles.length > 2 ? '...' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTimeOfDayIcon(String value) {
    switch (value) {
      case 'morning':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_twilight;
      case 'evening':
        return Icons.wb_cloudy;
      case 'night':
        return Icons.nightlight;
      default:
        return Icons.schedule;
    }
  }

  Future<void> _deleteReminder(String reminderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch nhắc'),
        content: const Text('Bạn có chắc chắn muốn xóa lịch nhắc này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _reminderService.deleteReminder(reminderId);
      // Refresh reminders list
      await _loadReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa lịch nhắc'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showFileInfo() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reminders.json');
      
      String filePath = file.path;
      String fileContent = '';
      bool fileExists = await file.exists();
      
      if (fileExists) {
        fileContent = await file.readAsString();
        // Format JSON for better readability
        try {
          final decoded = json.decode(fileContent) as Map<String, dynamic>;
          fileContent = const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (e) {
          // If formatting fails, use raw content
        }
      } else {
        fileContent = 'File chưa được tạo. File sẽ được tạo khi bạn đặt lịch nhắc đầu tiên.';
      }
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Color(0xFF2196F3)),
              SizedBox(width: 8),
              Text('Thông tin file dữ liệu'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Vị trí file:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    filePath,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trạng thái:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: fileExists ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fileExists ? 'Đã tồn tại' : 'Chưa tồn tại',
                        style: TextStyle(
                          color: fileExists ? Colors.green[800] : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: filePath));
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép đường dẫn'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Sao chép đường dẫn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                  ),
                ),
                if (fileExists) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Nội dung file:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        fileContent,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Lưu ý:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• File này được lưu tự động khi bạn đặt/xóa lịch nhắc\n'
                  '• Tất cả thay đổi được lưu vào file trong Documents directory',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đọc thông tin file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getTimeOfDayLabel(String value) {
    switch (value) {
      case 'morning':
        return 'Sáng';
      case 'afternoon':
        return 'Trưa';
      case 'evening':
        return 'Chiều';
      case 'night':
        return 'Tối';
      default:
        return '';
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'lotus':
        return Icons.wb_twilight;
      case 'book':
        return Icons.book;
      case 'library':
        return Icons.library_books;
      default:
        return Icons.category;
    }
  }

}

