import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../models/sutra.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Sutra sutra;
  final VoidCallback? onPlayStart;
  final VoidCallback? onPlayComplete;
  final VoidCallback? onPlayError;

  const AudioPlayerWidget({
    super.key,
    required this.sutra,
    this.onPlayStart,
    this.onPlayComplete,
    this.onPlayError,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _currentSpeechRate = 0.5;
  double _currentVolume = 1.0;
  double _currentPitch = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      // Kiểm tra TTS có sẵn không
      bool isTTSAvailable = await _audioService.isTTSAvailable();
      if (!isTTSAvailable) {
        _showErrorSnackBar('TTS không khả dụng. Emulator này có thể không có TTS engine. Thử tạo emulator mới với Google Play.');
        return;
      }

      await _audioService.initialize();
      
      // Set up callbacks
      _audioService.onStart = () {
        setState(() {
          _isPlaying = true;
          _isPaused = false;
        });
        widget.onPlayStart?.call();
      };

      _audioService.onComplete = () {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
        widget.onPlayComplete?.call();
      };

      _audioService.onPause = () {
        setState(() {
          _isPaused = true;
        });
      };

      _audioService.onResume = () {
        setState(() {
          _isPaused = false;
        });
      };

      _audioService.onError = (error) {
        setState(() {
          _isPlaying = false;
          _isPaused = false;
        });
        widget.onPlayError?.call();
        _showErrorSnackBar(error);
      };

      _currentSpeechRate = _audioService.speechRate;
      _currentVolume = _audioService.volume;
      _currentPitch = _audioService.pitch;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showErrorSnackBar('Không thể khởi tạo chức năng đọc bài: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _playAudio() async {
    if (!_isInitialized) return;

    try {
      if (widget.sutra.hasAudio && widget.sutra.audioPath != null) {
        // Play pre-recorded audio file
        // TODO: Implement audio file playback
        await _audioService.speak(widget.sutra.fullContent);
      } else {
        // Use TTS
        await _audioService.speak(widget.sutra.fullContent);
      }
    } catch (e) {
      _showErrorSnackBar('Không thể phát âm thanh: $e');
    }
  }

  Future<void> _pauseAudio() async {
    if (!_isInitialized) return;
    await _audioService.pause();
  }

  Future<void> _resumeAudio() async {
    if (!_isInitialized) return;
    await _audioService.resume();
  }

  Future<void> _stopAudio() async {
    if (!_isInitialized) return;
    await _audioService.stop();
  }

  Future<void> _playSlowly() async {
    if (!_isInitialized) return;
    await _audioService.speakSlowly(widget.sutra.fullContent);
  }

  Future<void> _playBySentences() async {
    if (!_isInitialized) return;
    await _audioService.speakBySentences(widget.sutra.fullContent);
  }

  Future<void> _checkTTSStatus() async {
    try {
      Map<String, dynamic> ttsInfo = await _audioService.getTTSInfo();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thông tin TTS'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trạng thái: ${ttsInfo['isAvailable'] ? 'Sẵn sàng' : 'Không khả dụng'}'),
              const SizedBox(height: 8),
              Text('Ngôn ngữ hiện tại: ${ttsInfo['currentLanguage'] ?? 'Không xác định'}'),
              const SizedBox(height: 8),
              Text('Số ngôn ngữ hỗ trợ: ${(ttsInfo['languages'] as List).length}'),
              if (ttsInfo['error'] != null) ...[
                const SizedBox(height: 8),
                Text('Lỗi: ${ttsInfo['error']}', style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Không thể kiểm tra TTS: $e');
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.volume_up,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Đọc bài kinh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Audio status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.sutra.canPlayAudio 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.sutra.audioStatusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.sutra.canPlayAudio 
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause button
                _buildControlButton(
                  icon: _isPlaying && !_isPaused 
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  label: _isPlaying && !_isPaused ? 'Tạm dừng' : 'Phát',
                  onPressed: _isPlaying && !_isPaused ? _pauseAudio : _playAudio,
                  color: Colors.blue,
                  size: 48,
                ),

                // Stop button
                _buildControlButton(
                  icon: Icons.stop_circle,
                  label: 'Dừng',
                  onPressed: _stopAudio,
                  color: Colors.red,
                  size: 40,
                ),

                // Resume button (only show when paused)
                if (_isPaused)
                  _buildControlButton(
                    icon: Icons.play_circle_filled,
                    label: 'Tiếp tục',
                    onPressed: _resumeAudio,
                    color: Colors.green,
                    size: 40,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Special controls for elderly users
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Slow play button
                _buildControlButton(
                  icon: Icons.slow_motion_video,
                  label: 'Đọc chậm',
                  onPressed: _playSlowly,
                  color: Colors.orange,
                  size: 36,
                ),

                // Sentence by sentence button
                _buildControlButton(
                  icon: Icons.format_list_numbered,
                  label: 'Từng câu',
                  onPressed: _playBySentences,
                  color: Colors.purple,
                  size: 36,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TTS Status
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đọc trực tiếp từ nội dung text bằng TTS',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _checkTTSStatus,
                    child: const Text('Kiểm tra', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Settings section
            ExpansionTile(
              title: const Text(
                'Cài đặt đọc',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              leading: const Icon(Icons.settings),
              children: [
                // Speech rate slider
                _buildSliderControl(
                  title: 'Tốc độ đọc',
                  value: _currentSpeechRate,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: (value) async {
                    setState(() {
                      _currentSpeechRate = value;
                    });
                    await _audioService.setSpeechRate(value);
                  },
                  valueText: '${(_currentSpeechRate * 100).round()}%',
                ),

                // Volume slider
                _buildSliderControl(
                  title: 'Âm lượng',
                  value: _currentVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) async {
                    setState(() {
                      _currentVolume = value;
                    });
                    await _audioService.setVolume(value);
                  },
                  valueText: '${(_currentVolume * 100).round()}%',
                ),

                // Pitch slider
                _buildSliderControl(
                  title: 'Cao độ giọng',
                  value: _currentPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  onChanged: (value) async {
                    setState(() {
                      _currentPitch = value;
                    });
                    await _audioService.setPitch(value);
                  },
                  valueText: _currentPitch.toStringAsFixed(1),
                ),
              ],
            ),

            // Audio info
            if (widget.sutra.hasAudio) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Thời lượng: ${widget.sutra.audioDisplayDuration}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required double size,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: size),
          color: color,
          style: IconButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            shape: const CircleBorder(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderControl({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                valueText,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
