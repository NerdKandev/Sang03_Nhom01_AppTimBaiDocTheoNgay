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
  
  // Pagination
  final PageController _pageController = PageController();
  List<String> _contentPages = [];
  int _currentPage = 0;
  bool _needsPagination = false;
  
  // Audio mode selection
  bool? _selectedAudioMode; // null = chưa chọn, true = Audio File, false = TTS
  
  @override
  void initState() {
    super.initState();
    // Default to Audio File if sutra has audio
    if (widget.sutra.hasAudio && widget.sutra.audioPath != null) {
      _selectedAudioMode = true;
    }
    // Will be called in build method after first frame
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Widget _buildAudioModeSelector() {
    // Default to Audio File if not selected yet
    final selectedMode = _selectedAudioMode ?? true;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2196F3).withOpacity(0.1),
              const Color(0xFF2196F3).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  color: const Color(0xFF2196F3),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Chọn chế độ nghe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Audio File Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAudioMode = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedMode 
                            ? const Color(0xFF2196F3) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedMode 
                              ? const Color(0xFF2196F3) 
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.library_music,
                            size: 32,
                            color: selectedMode ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Audio File',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: selectedMode ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nghe từ file',
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedMode ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // TTS Option
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAudioMode = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: !selectedMode 
                            ? const Color(0xFF2196F3) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !selectedMode 
                              ? const Color(0xFF2196F3) 
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.volume_up,
                            size: 32,
                            color: !selectedMode ? Colors.white : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TTS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: !selectedMode ? Colors.white : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đọc tự động',
                            style: TextStyle(
                              fontSize: 12,
                              color: !selectedMode ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _splitContentIntoPages() {
    final fullContent = widget.sutra.fullContent;
    if (fullContent.isEmpty) {
      _contentPages = [''];
      _needsPagination = false;
      return;
    }
    
    // Estimate characters per page based on font size, line height, and screen size
    // Formula: approximate chars per line * lines per page
    // Average Vietnamese character width ≈ fontSize * 0.6
    // Screen width (assuming padding) ≈ 350dp
    final screenWidth = MediaQuery.of(context).size.width - 80; // Account for padding
    final charsPerLine = (screenWidth / (_fontSize * 0.6)).round();
    final linesPerPage = ((MediaQuery.of(context).size.height * 0.5) / (_fontSize * _lineHeight)).round();
    final charsPerPage = (charsPerLine * linesPerPage * 0.9).round(); // 90% to account for margins
    
    // Minimum chars per page to avoid too many pages
    final minCharsPerPage = (_fontSize * 40).round();
    final actualCharsPerPage = charsPerPage > minCharsPerPage ? charsPerPage : minCharsPerPage;
    
    // Split content into pages
    _contentPages = [];
    int startIndex = 0;
    
    while (startIndex < fullContent.length) {
      int endIndex = startIndex + actualCharsPerPage;
      
      if (endIndex >= fullContent.length) {
        // Last page
        _contentPages.add(fullContent.substring(startIndex).trim());
        break;
      }
      
      // Try to break at sentence boundary (period, exclamation, question mark)
      int lastPeriod = fullContent.lastIndexOf('.', endIndex);
      int lastExclamation = fullContent.lastIndexOf('!', endIndex);
      int lastQuestion = fullContent.lastIndexOf('?', endIndex);
      int lastBreak = [lastPeriod, lastExclamation, lastQuestion].reduce((a, b) => a > b ? a : b);
      
      // If found a sentence break within reasonable distance, use it
      if (lastBreak > startIndex + actualCharsPerPage * 0.7) {
        endIndex = lastBreak + 1;
      } else {
        // Try to break at paragraph or line break
        int lastNewline = fullContent.lastIndexOf('\n', endIndex);
        if (lastNewline > startIndex + actualCharsPerPage * 0.7) {
          endIndex = lastNewline + 1;
        } else {
          // Try to break at space
          int lastSpace = fullContent.lastIndexOf(' ', endIndex);
          if (lastSpace > startIndex + actualCharsPerPage * 0.8) {
            endIndex = lastSpace + 1;
          }
        }
      }
      
      _contentPages.add(fullContent.substring(startIndex, endIndex).trim());
      startIndex = endIndex;
    }
    
    _needsPagination = _contentPages.length > 1;
    if (_contentPages.isEmpty) {
      _contentPages = [fullContent];
      _needsPagination = false;
    }
  }
  
  void _updatePagination() {
    _splitContentIntoPages();
    setState(() {
      _currentPage = 0;
      _pageController.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize pagination on first build
    if (_contentPages.isEmpty && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _splitContentIntoPages();
          });
        }
      });
    }
    
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
              
              // Audio Mode Selection (only if sutra has audio)
              if (widget.sutra.hasAudio && widget.sutra.audioPath != null) ...[
                _buildAudioModeSelector(),
                const SizedBox(height: 16),
              ],
              
              // Audio Player Widget
              AudioPlayerWidget(
                sutra: widget.sutra,
                useAudioFile: _selectedAudioMode,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nội dung:',
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  if (_needsPagination)
                    Text(
                      'Trang ${_currentPage + 1}/${_contentPages.length}',
                      style: TextStyle(
                        fontSize: _fontSize - 2,
                        color: _textColor.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Main Content with Pagination
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: _needsPagination
                    ? PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _contentPages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            margin: const EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: _backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _textColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _contentPages[index],
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  height: _lineHeight,
                                  color: _textColor,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
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
                        child: SingleChildScrollView(
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
                      ),
              ),
              
              // Page Navigation Controls
              if (_needsPagination) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      tooltip: 'Trang trước',
                    ),
                    const SizedBox(width: 16),
                    Wrap(
                      spacing: 8,
                      children: List.generate(
                        _contentPages.length,
                        (index) => GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < _contentPages.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      tooltip: 'Trang sau',
                    ),
                  ],
                ),
              ],
              
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
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
                  // Update dialog state for immediate UI feedback
                  setDialogState(() {
                    _fontSize = value;
                  });
                  // Update main screen state for real-time changes
                  setState(() {
                    _fontSize = value;
                  });
                  _updatePagination();
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
                  // Update dialog state for immediate UI feedback
                  setDialogState(() {
                    _lineHeight = value;
                  });
                  // Update main screen state for real-time changes
                  setState(() {
                    _lineHeight = value;
                  });
                  _updatePagination();
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
                  _buildColorOptionInDialog(Colors.white, 'Trắng', setDialogState),
                  const SizedBox(width: 8),
                  _buildColorOptionInDialog(Colors.amber[50]!, 'Vàng nhạt', setDialogState),
                  const SizedBox(width: 8),
                  _buildColorOptionInDialog(const Color(0xFF2196F3), 'Xanh nhạt', setDialogState),
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
                  _buildTextColorOptionInDialog(Colors.black, 'Đen', setDialogState),
                  const SizedBox(width: 8),
                  _buildTextColorOptionInDialog(Colors.brown, 'Nâu', setDialogState),
                  const SizedBox(width: 8),
                  _buildTextColorOptionInDialog(const Color(0xFF2196F3), 'Xanh đậm', setDialogState),
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
      ),
    );
  }

  Widget _buildColorOptionInDialog(Color color, String label, StateSetter setDialogState) {
    return GestureDetector(
      onTap: () {
        // Update dialog state for immediate UI feedback
        setDialogState(() {
          _backgroundColor = color;
        });
        // Update main screen state for real-time changes
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

  Widget _buildTextColorOptionInDialog(Color color, String label, StateSetter setDialogState) {
    return GestureDetector(
      onTap: () {
        // Update dialog state for immediate UI feedback
        setDialogState(() {
          _textColor = color;
        });
        // Update main screen state for real-time changes
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

