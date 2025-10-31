import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;
  String _language = 'Tiếng Việt';
  String _fontSize = 'Bình thường';

  @override
  void initState() {
    super.initState();
    // initialize from the shared notifier so changes apply immediately
    final s = settingsNotifier.value;
    _isDark = s.isDark;
    // map scale back to label
    if (s.textScaleFactor <= 0.95) {
      _fontSize = 'Nhỏ';
    } else if (s.textScaleFactor >= 1.15) {
      _fontSize = 'Lớn';
    } else {
      _fontSize = 'Bình thường';
    }
    settingsNotifier.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    final s = settingsNotifier.value;
    setState(() {
      _isDark = s.isDark;
      if (s.textScaleFactor <= 0.95) {
        _fontSize = 'Nhỏ';
      } else if (s.textScaleFactor >= 1.15) {
        _fontSize = 'Lớn';
      } else {
        _fontSize = 'Bình thường';
      }
    });
  }

  void _setDark(bool v) {
    setState(() => _isDark = v);
    // persist and notify app
    saveIsDark(v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(v ? 'Chế độ tối bật' : 'Chế độ tối tắt')),
    );
  }

  void _setLanguage(String v) {
    setState(() => _language = v);
    saveLanguage(v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ngôn ngữ: $v')),
    );
  }

  void _setFontSize(String v) {
    setState(() => _fontSize = v);
    // persist and notify app-wide change
    saveFont(v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cỡ chữ: $v')),
    );
  }

  @override
  void dispose() {
    settingsNotifier.removeListener(_onSettingsChanged);
    super.dispose();
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quản lý tuỳ chọn ứng dụng của bạn', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),

          // Dark mode card
          _buildCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Chế độ tối', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Bật/tắt chế độ tối'),
                  ],
                ),
                Switch(
                  value: _isDark,
                  onChanged: _setDark,
                ),
              ],
            ),
          ),

          // Font size card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kích thước chữ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _setFontSize('Nhỏ'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fontSize == 'Nhỏ' ? theme.colorScheme.primary : theme.colorScheme.surface,
                          foregroundColor: _fontSize == 'Nhỏ' ? Colors.white : theme.colorScheme.onSurface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Nhỏ')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _setFontSize('Bình thường'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fontSize == 'Bình thường' ? theme.colorScheme.primary : theme.colorScheme.surface,
                          foregroundColor: _fontSize == 'Bình thường' ? Colors.white : theme.colorScheme.onSurface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Bình thường')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _setFontSize('Lớn'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _fontSize == 'Lớn' ? theme.colorScheme.primary : theme.colorScheme.surface,
                          foregroundColor: _fontSize == 'Lớn' ? Colors.white : theme.colorScheme.onSurface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Lớn')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}
