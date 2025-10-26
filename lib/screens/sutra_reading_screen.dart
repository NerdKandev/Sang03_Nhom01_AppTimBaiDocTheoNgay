import 'package:flutter/material.dart';
import '../models/sutra.dart';
import '../widgets/audio_player_widget.dart';
import '../services/data_service.dart';

class SutraReadingScreen extends StatefulWidget {
  final Sutra sutra;

  const SutraReadingScreen({
    super.key,
    required this.sutra,
  });

  @override
  State<SutraReadingScreen> createState() => _SutraReadingScreenState();
}

class _SutraReadingScreenState extends State<SutraReadingScreen> {
  double _fontSize = 18.0;
  double _lineHeight = 1.6;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.sutra.titleVietnamese,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
  backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Quay lại',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _quickPlay,
            tooltip: 'Đọc nhanh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: 'Cài đặt đọc',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sutra Info Card
              Card(
                elevation: 4,
                color: const Color(0xFF2196F3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.sutra.title,
                        style: TextStyle(
                          fontSize: _fontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.sutra.titlePali,
                        style: TextStyle(
                          fontSize: _fontSize - 2,
                          fontStyle: FontStyle.italic,
                          color: _textColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildInfoChip(
                            widget.sutra.category,
                            const Color(0xFF2196F3),
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            widget.sutra.difficulty,
                            _getDifficultyColor(widget.sutra.difficulty),
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            widget.sutra.readingTime,
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              // Cover image (use asset if available; errorBuilder gives a graceful fallback)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.sutra.coverImage ?? 'assets/images/placeholder.jpg',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 56,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Audio Player Widget
              AudioPlayerWidget(
                sutra: widget.sutra,
                onPlayStart: () {
                  // Update reading count when audio starts
                  _dataService.updateReadingCount(widget.sutra.id);
                },
                onPlayComplete: () {
                  // Show completion message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đọc xong bài kinh'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onPlayError: () {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Có lỗi xảy ra khi đọc bài kinh'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Description
              if (widget.sutra.description.isNotEmpty) ...[
                Text(
                  'Mô tả:',
                  style: TextStyle(
                    fontSize: _fontSize + 4,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.sutra.description,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: _lineHeight,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Content
              Text(
                'Nội dung:',
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Main Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _textColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.sutra.fullContent,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: _lineHeight,
                    color: _textColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Tags
              if (widget.sutra.tags.isNotEmpty) ...[
                Text(
                  'Từ khóa:',
                  style: TextStyle(
                    fontSize: _fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.sutra.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontSize: _fontSize - 2,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: const Color(0xFF2196F3),
                  )).toList(),
                ),
                const SizedBox(height: 32),
              ],
              
              // Reading Progress
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ đọc:',
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          Text(
                            'Hoàn thành',
                            style: TextStyle(
                              fontSize: _fontSize - 2,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSettingsDialog,
  backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.text_fields, color: Colors.white),
        tooltip: 'Cài đặt đọc',
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: _fontSize - 2,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return Colors.green;
      case 'Trung bình':
        return Colors.orange;
      case 'Khó':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _quickPlay() {
    // Show quick play options
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn cách đọc',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Color(0xFF2196F3)),
              title: const Text('Đọc bình thường'),
              onTap: () {
                Navigator.pop(context);
                // This will be handled by the AudioPlayerWidget
              },
            ),
            ListTile(
              leading: const Icon(Icons.slow_motion_video, color: Colors.orange),
              title: const Text('Đọc chậm'),
              onTap: () {
                Navigator.pop(context);
                // This will be handled by the AudioPlayerWidget
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_list_numbered, color: Colors.purple),
              title: const Text('Đọc từng câu'),
              onTap: () {
                Navigator.pop(context);
                // This will be handled by the AudioPlayerWidget
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt đọc'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Font Size
            Text(
              'Kích thước chữ: ${_fontSize.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _fontSize,
              min: 14.0,
              max: 28.0,
              divisions: 14,
              label: _fontSize.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Line Height
            Text(
              'Khoảng cách dòng: ${_lineHeight.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _lineHeight,
              min: 1.2,
              max: 2.0,
              divisions: 8,
              label: _lineHeight.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _lineHeight = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Background Color
            Text(
              'Màu nền:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildColorOption(Colors.white, 'Trắng'),
                const SizedBox(width: 8),
                _buildColorOption(Colors.amber[50]!, 'Vàng nhạt'),
                const SizedBox(width: 8),
                _buildColorOption(const Color(0xFF2196F3), 'Xanh nhạt'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Text Color
            Text(
              'Màu chữ:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTextColorOption(Colors.black, 'Đen'),
                const SizedBox(width: 8),
                _buildTextColorOption(Colors.brown, 'Nâu'),
                const SizedBox(width: 8),
                _buildTextColorOption(const Color(0xFF2196F3), 'Xanh đậm'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _backgroundColor == color ? const Color(0xFF2196F3) : Colors.grey,
            width: 2,
          ),
        ),
        child: _backgroundColor == color
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _buildTextColorOption(Color color, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textColor = color;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _textColor == color ? const Color(0xFF2196F3) : Colors.grey,
            width: 2,
          ),
        ),
        child: _textColor == color
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

