import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  String _currentText = '';
  double _speechRate = 0.5; // Tốc độ đọc (0.1 - 1.0)
  double _volume = 1.0; // Âm lượng (0.0 - 1.0)
  double _pitch = 1.0; // Cao độ giọng (0.5 - 2.0)

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  double get volume => _volume;
  double get pitch => _pitch;

  // Callbacks
  Function()? onStart;
  Function()? onComplete;
  Function()? onPause;
  Function()? onResume;
  Function(String)? onError;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Kiểm tra TTS có sẵn không
      var languages = await _flutterTts.getLanguages;
      if (languages == null || languages.isEmpty) {
        throw Exception('TTS không khả dụng trên thiết bị này');
      }

      // Cấu hình TTS với fallback
      String language = "vi-VN";
      if (!languages.contains("vi-VN")) {
        // Fallback to English if Vietnamese not available
        language = "en-US";
      }
      
      // Nếu không có English, dùng ngôn ngữ đầu tiên có sẵn
      if (!languages.contains("en-US") && languages.isNotEmpty) {
        language = languages.first.toString();
      }
      
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      // Thiết lập callbacks
      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        _isPaused = false;
        onStart?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _isPaused = false;
        onComplete?.call();
      });

      _flutterTts.setPauseHandler(() {
        _isPaused = true;
        onPause?.call();
      });

      _flutterTts.setContinueHandler(() {
        _isPaused = false;
        onResume?.call();
      });

      _flutterTts.setErrorHandler((message) {
        _isPlaying = false;
        _isPaused = false;
        onError?.call(message);
      });

      // Load settings từ SharedPreferences
      await _loadSettings();

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
      onError?.call('Không thể khởi tạo chức năng đọc bài: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _speechRate = prefs.getDouble('tts_speech_rate') ?? 0.5;
      _volume = prefs.getDouble('tts_volume') ?? 1.0;
      _pitch = prefs.getDouble('tts_pitch') ?? 1.0;
      
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);
    } catch (e) {
      print('Error loading TTS settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('tts_speech_rate', _speechRate);
      await prefs.setDouble('tts_volume', _volume);
      await prefs.setDouble('tts_pitch', _pitch);
    } catch (e) {
      print('Error saving TTS settings: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      _currentText = text;
      
      // Dừng đọc hiện tại nếu có
      if (_isPlaying) {
        await stop();
      }

      // Clean text: remove excessive whitespace and normalize
      String cleanedText = _cleanText(text);
      
      // Split long text into chunks if needed (TTS has character limits on some platforms)
      const int maxChunkLength = 4000; // Safe limit for most TTS engines
      
      if (cleanedText.length > maxChunkLength) {
        // Split into chunks and read sequentially
        List<String> chunks = _splitIntoChunks(cleanedText, maxChunkLength);
        await _speakChunksSequentially(chunks);
      } else {
        // Read normally for shorter text
        await _speakTextWithRetry(cleanedText);
      }
    } catch (e) {
      print('Error speaking text: $e');
      onError?.call('Không thể đọc văn bản. Vui lòng kiểm tra cài đặt TTS trên thiết bị.');
    }
  }

  String _cleanText(String text) {
    // Remove excessive newlines and whitespace
    String cleaned = text.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // Max 2 newlines
    cleaned = cleaned.replaceAll(RegExp(r' {3,}'), ' '); // Max 1 space
    cleaned = cleaned.trim();
    return cleaned;
  }

  List<String> _splitIntoChunks(String text, int maxLength) {
    List<String> chunks = [];
    int startIndex = 0;
    
    while (startIndex < text.length) {
      int endIndex = startIndex + maxLength;
      
      if (endIndex >= text.length) {
        // Last chunk
        chunks.add(text.substring(startIndex));
        break;
      }
      
      // Try to split at sentence boundary
      int lastPeriod = text.lastIndexOf('.', endIndex);
      int lastExclamation = text.lastIndexOf('!', endIndex);
      int lastQuestion = text.lastIndexOf('?', endIndex);
      int lastLineBreak = text.lastIndexOf('\n', endIndex);
      
      int bestBreak = [lastPeriod, lastExclamation, lastQuestion, lastLineBreak]
          .where((i) => i > startIndex + maxLength * 0.7)
          .fold<int>(-1, (a, b) => a > b ? a : b);
      
      if (bestBreak > startIndex) {
        endIndex = bestBreak + 1;
      } else {
        // Fallback: split at space
        int lastSpace = text.lastIndexOf(' ', endIndex);
        if (lastSpace > startIndex) {
          endIndex = lastSpace + 1;
        }
      }
      
      chunks.add(text.substring(startIndex, endIndex).trim());
      startIndex = endIndex;
    }
    
    return chunks;
  }

  Future<void> _speakChunksSequentially(List<String> chunks) async {
    for (int i = 0; i < chunks.length; i++) {
      String chunk = chunks[i];
      if (chunk.trim().isEmpty) continue;
      
      await _speakTextWithRetry(chunk);
      
      // Wait for current chunk to finish before starting next
      while (_isPlaying) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Small delay between chunks for smoother transition
      if (i < chunks.length - 1) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Future<void> _speakTextWithRetry(String text) async {
    bool success = false;
    int retryCount = 0;
    const maxRetries = 3;

    while (!success && retryCount < maxRetries) {
      try {
        await _flutterTts.speak(text);
        success = true;
      } catch (e) {
        retryCount++;
        print('TTS Error (attempt $retryCount): $e');
        
        if (retryCount < maxRetries) {
          // Đợi một chút trước khi thử lại
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          
          // Thử khởi tạo lại TTS
          if (retryCount == 2) {
            try {
              await _flutterTts.stop();
              await Future.delayed(const Duration(milliseconds: 1000));
              await initialize();
            } catch (initError) {
              print('Error reinitializing TTS: $initError');
            }
          }
        } else {
          throw e;
        }
      }
    }
  }

  Future<void> pause() async {
    if (!_isInitialized || !_isPlaying) return;

    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Error pausing TTS: $e');
      onError?.call('Không thể tạm dừng: $e');
    }
  }

  Future<void> resume() async {
    if (!_isInitialized || !_isPaused) return;

    try {
      await _flutterTts.speak(_currentText);
    } catch (e) {
      print('Error resuming TTS: $e');
      onError?.call('Không thể tiếp tục: $e');
    }
  }

  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
      _isPlaying = false;
      _isPaused = false;
      _currentText = '';
    } catch (e) {
      print('Error stopping TTS: $e');
      onError?.call('Không thể dừng: $e');
    }
  }

  Future<void> setSpeechRate(double rate) async {
    if (rate < 0.1 || rate > 1.0) return;

    _speechRate = rate;
    await _flutterTts.setSpeechRate(_speechRate);
    await _saveSettings();
  }

  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) return;

    _volume = volume;
    await _flutterTts.setVolume(_volume);
    await _saveSettings();
  }

  Future<void> setPitch(double pitch) async {
    if (pitch < 0.5 || pitch > 2.0) return;

    _pitch = pitch;
    await _flutterTts.setPitch(_pitch);
    await _saveSettings();
  }

  // Lấy danh sách các ngôn ngữ có sẵn
  Future<List<dynamic>> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      print('Error getting available languages: $e');
      return [];
    }
  }

  // Lấy danh sách các giọng đọc có sẵn
  Future<List<dynamic>> getAvailableVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      print('Error getting available voices: $e');
      return [];
    }
  }

  // Đọc với giọng cụ thể
  Future<void> speakWithVoice(String text, String voice) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts.setVoice({"name": voice, "locale": "vi-VN"});
      await speak(text);
    } catch (e) {
      print('Error speaking with voice: $e');
      onError?.call('Không thể đọc với giọng đã chọn: $e');
    }
  }

  // Đọc từng câu (phù hợp cho người lớn tuổi)
  Future<void> speakBySentences(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Clean text first
    String cleanedText = _cleanText(text);
    
    // Tách văn bản thành các câu
    List<String> sentences = _splitIntoSentences(cleanedText);
    
    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;
      
      // Use the retry mechanism for each sentence
      await _speakTextWithRetry(sentence);
      
      // Đợi câu hiện tại đọc xong trước khi đọc câu tiếp theo
      while (_isPlaying) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Small pause between sentences for clarity
      if (i < sentences.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  List<String> _splitIntoSentences(String text) {
    // Tách văn bản thành các câu dựa trên dấu chấm, chấm hỏi, chấm than, xuống dòng
    List<String> sentences = [];
    String currentSentence = '';
    
    for (int i = 0; i < text.length; i++) {
      currentSentence += text[i];
      
      // Check for sentence endings
      if (text[i] == '.' || text[i] == '!' || text[i] == '?' || text[i] == '。') {
        // Check if next char is whitespace or end of text
        if (i == text.length - 1 || text[i + 1].trim().isEmpty) {
          String trimmed = currentSentence.trim();
          if (trimmed.isNotEmpty) {
            sentences.add(trimmed);
          }
          currentSentence = '';
        }
      } else if (text[i] == '\n' && currentSentence.trim().isNotEmpty) {
        // Also split on newlines if they're not followed by more newlines
        if (i == text.length - 1 || text[i + 1] != '\n') {
          String trimmed = currentSentence.trim();
          if (trimmed.isNotEmpty) {
            sentences.add(trimmed);
          }
          currentSentence = '';
        }
      }
    }
    
    // Thêm câu cuối nếu còn
    String lastSentence = currentSentence.trim();
    if (lastSentence.isNotEmpty) {
      sentences.add(lastSentence);
    }
    
    return sentences;
  }

  // Đọc với tốc độ chậm (phù hợp cho người lớn tuổi)
  Future<void> speakSlowly(String text) async {
    double originalRate = _speechRate;
    await setSpeechRate(0.3); // Tốc độ rất chậm
    await speak(text);
    await setSpeechRate(originalRate); // Khôi phục tốc độ ban đầu
  }

  // Kiểm tra TTS status
  Future<bool> isTTSAvailable() async {
    try {
      var languages = await _flutterTts.getLanguages;
      return languages != null && languages.isNotEmpty;
    } catch (e) {
      print('Error checking TTS availability: $e');
      return false;
    }
  }

  // Lấy thông tin TTS
  Future<Map<String, dynamic>> getTTSInfo() async {
    try {
      var languages = await _flutterTts.getLanguages;
      var voices = await _flutterTts.getVoices;
      
      return {
        'isAvailable': languages != null && languages.isNotEmpty,
        'languages': languages ?? [],
        'voices': voices ?? [],
        'currentLanguage': 'vi-VN', // Default language
      };
    } catch (e) {
      print('Error getting TTS info: $e');
      return {
        'isAvailable': false,
        'languages': [],
        'voices': [],
        'currentLanguage': null,
        'error': e.toString(),
      };
    }
  }

  // Dispose
  Future<void> dispose() async {
    try {
      await _flutterTts.stop();
      _isInitialized = false;
    } catch (e) {
      print('Error disposing TTS: $e');
    }
  }
}
