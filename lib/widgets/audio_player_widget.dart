import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/audio_service.dart';
import '../models/sutra.dart';

class AudioPlayerWidget extends StatefulWidget {
  final Sutra sutra;
  final VoidCallback? onPlayStart;
  final VoidCallback? onPlayComplete;
  final VoidCallback? onPlayError;
  final bool? useAudioFile; // Override for audio mode selection

  const AudioPlayerWidget({
    super.key,
    required this.sutra,
    this.onPlayStart,
    this.onPlayComplete,
    this.onPlayError,
    this.useAudioFile,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioService _audioService = AudioService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _currentSpeechRate = 0.5;
  double _currentVolume = 1.0;
  double _currentPitch = 1.0;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _isLoadingAudio = false;
  bool _useAudioFile = true; // Toggle between audio file and TTS
  bool _isSeeking = false; // Track if user is dragging slider

  @override
  void initState() {
    super.initState();
    // Use provided value or default based on sutra
    _useAudioFile = widget.useAudioFile ?? 
        (widget.sutra.hasAudio && widget.sutra.audioPath != null);
    _initializeAudio();
    _setupAudioPlayerListeners();
  }
  
  @override
  void didUpdateWidget(AudioPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if external selection changes
    if (widget.useAudioFile != null && widget.useAudioFile != oldWidget.useAudioFile) {
      _stopAudio();
      setState(() {
        _useAudioFile = widget.useAudioFile!;
      });
    }
  }


  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        _isPaused = state == PlayerState.paused;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _audioDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!_isSeeking) {
        setState(() {
          _audioPosition = position;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
      widget.onPlayComplete?.call();
    });
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

  void _showErrorSnackBar(String message, {bool isWarning = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isWarning ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _playTTS() async {
    try {
      // Stop any currently playing audio first
      await _stopAudio();
      
      // Ensure TTS is initialized
      if (!_isInitialized) {
        await _initializeAudio();
        // Check again after initialization
        if (!_isInitialized) {
          _showErrorSnackBar('Không thể khởi tạo TTS. Vui lòng kiểm tra cài đặt TTS trên thiết bị.');
          widget.onPlayError?.call();
          return;
        }
      }
      
      // Check if TTS is available
      bool isAvailable = await _audioService.isTTSAvailable();
      if (!isAvailable) {
        _showErrorSnackBar('TTS không khả dụng trên thiết bị này. Vui lòng cài đặt TTS engine.');
        widget.onPlayError?.call();
        return;
      }
      
      // Get content - use fullContent if available
      String content = widget.sutra.fullContent.isNotEmpty 
          ? widget.sutra.fullContent 
          : widget.sutra.content;
      
      if (content.isEmpty) {
        _showErrorSnackBar('Bài đọc này không có nội dung để đọc.');
        return;
      }
      
      await _audioService.speak(content);
    } catch (e) {
      print('Error in _playTTS: $e');
      _showErrorSnackBar('Không thể phát TTS: $e');
      widget.onPlayError?.call();
    }
  }
  
  Future<void> _playAudioFile() async {
    try {
      // Stop any currently playing audio first
      await _stopAudio();
      
      if (!widget.sutra.hasAudio || widget.sutra.audioPath == null) {
        _showErrorSnackBar('Bài đọc này không có file audio. Đang chuyển sang TTS...', isWarning: true);
        // Automatically switch to TTS
        setState(() {
          _useAudioFile = false;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        await _playTTS();
        return;
      }
      
      setState(() {
        _isLoadingAudio = true;
      });

      // Extract filename from assets/audio/filename.mp3
      String audioAssetPath = widget.sutra.audioPath!;
      if (audioAssetPath.startsWith('assets/audio/')) {
        // Remove 'assets/' prefix for AssetSource
        audioAssetPath = audioAssetPath.replaceFirst('assets/', '');
        await _audioPlayer.play(AssetSource(audioAssetPath));
        
        // Reset position when starting new playback
        setState(() {
          _isLoadingAudio = false;
          _isPlaying = true;
          _audioPosition = Duration.zero;
          _isSeeking = false;
        });
        
        widget.onPlayStart?.call();
      } else {
        throw Exception('Đường dẫn audio không hợp lệ');
      }
    } catch (e) {
      setState(() {
        _isLoadingAudio = false;
      });
      
      // Check if error is about missing asset
      String errorMessage = e.toString();
      if (errorMessage.contains('Unable to load asset') || 
          errorMessage.contains('does not exist') ||
          errorMessage.contains('empty data')) {
        // Automatically fallback to TTS
        _showErrorSnackBar('File audio không tìm thấy. Đang chuyển sang TTS...', isWarning: true);
        setState(() {
          _useAudioFile = false;
        });
        await Future.delayed(const Duration(milliseconds: 500));
        await _playTTS();
      } else {
        _showErrorSnackBar('Không thể phát file audio: $e');
        widget.onPlayError?.call();
      }
    }
  }

  Future<void> _pauseAudio() async {
    // Stop both audio player and TTS to be safe
    try {
      if (widget.sutra.hasAudio && widget.sutra.audioPath != null) {
        await _audioPlayer.pause();
      }
    } catch (e) {
      print('Error pausing audio player: $e');
    }
    
    try {
      if (_isInitialized) {
        await _audioService.pause();
      }
    } catch (e) {
      print('Error pausing TTS: $e');
    }
  }

  Future<void> _resumeAudio() async {
    if (_isPlaying && _useAudioFile && widget.sutra.hasAudio && widget.sutra.audioPath != null) {
      await _audioPlayer.resume();
    } else if (_isInitialized) {
      await _audioService.resume();
    }
  }

  Future<void> _stopAudio() async {
    // Stop both audio player and TTS to ensure clean state
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio player: $e');
    }
    
    try {
      if (_isInitialized) {
        await _audioService.stop();
      }
    } catch (e) {
      print('Error stopping TTS: $e');
    }
    
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _audioPosition = Duration.zero;
      _audioDuration = Duration.zero;
      _isSeeking = false;
    });
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
    _audioPlayer.dispose();
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

            // Show current mode if externally controlled
            if (widget.useAudioFile != null && widget.sutra.hasAudio && widget.sutra.audioPath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _useAudioFile ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _useAudioFile ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _useAudioFile ? Icons.library_music : Icons.volume_up,
                      color: _useAudioFile ? Colors.green : const Color(0xFF2196F3),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _useAudioFile ? 'Đang dùng: Audio File' : 'Đang dùng: TTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _useAudioFile ? Colors.green[700] : const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Main controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause button
                _isLoadingAudio
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      )
                    : _buildControlButton(
                        icon: _isPlaying && !_isPaused 
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        label: _isPlaying && !_isPaused ? 'Tạm dừng' : 'Phát',
                        onPressed: _isPlaying && !_isPaused 
                            ? _pauseAudio 
                            : ((_useAudioFile && widget.sutra.hasAudio && widget.sutra.audioPath != null)
                                ? _playAudioFile
                                : _playTTS),
                        color: const Color(0xFF2196F3),
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
                // Slow play button (only for TTS)
                if ((!widget.sutra.hasAudio || widget.sutra.audioPath == null) || !_useAudioFile)
                  _buildControlButton(
                    icon: Icons.slow_motion_video,
                    label: 'Đọc chậm',
                    onPressed: _playSlowly,
                    color: Colors.orange,
                    size: 36,
                  ),

                // Sentence by sentence button (only for TTS)
                if ((!widget.sutra.hasAudio || widget.sutra.audioPath == null) || !_useAudioFile)
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

            // Audio file or TTS Status
            if (widget.sutra.hasAudio && widget.sutra.audioPath != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audiotrack, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phát từ file audio',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (_audioDuration != Duration.zero || _audioPosition != Duration.zero) ...[
                            const SizedBox(height: 12),
                            // Time display: current / total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_audioPosition),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_audioDuration != Duration.zero ? _audioDuration : Duration.zero),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Seekable slider
                            if (_audioDuration != Duration.zero && _audioDuration.inMilliseconds > 0)
                              Slider(
                                value: _audioPosition.inMilliseconds.clamp(0, _audioDuration.inMilliseconds).toDouble(),
                                min: 0,
                                max: _audioDuration.inMilliseconds.toDouble(),
                                onChanged: (value) {
                                  setState(() {
                                    _isSeeking = true;
                                    _audioPosition = Duration(milliseconds: value.toInt());
                                  });
                                },
                                onChangeEnd: (value) async {
                                  final seekPosition = Duration(milliseconds: value.toInt());
                                  try {
                                    await _audioPlayer.seek(seekPosition);
                                    setState(() {
                                      _isSeeking = false;
                                      _audioPosition = seekPosition;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _isSeeking = false;
                                    });
                                    print('Error seeking audio: $e');
                                  }
                                },
                                activeColor: Colors.green,
                                inactiveColor: Colors.grey[400],
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // TTS Status
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đọc trực tiếp từ nội dung text bằng TTS',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF2196F3),
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
            ],

            // Settings section (only for TTS)
            if (!widget.sutra.hasAudio || widget.sutra.audioPath == null)
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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
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
