import 'dart:math';
import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/sutra_card.dart';
import '../models/sutra.dart';
import 'sutra_reading_screen.dart';
import 'settings_screen.dart';
import 'reminder_screen.dart';
import 'favorites_screen.dart';
import 'videos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final DataService _dataService = DataService();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  bool _showAudioOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📿 Đọc Kinh Hàng Ngày'),
  backgroundColor: const Color(0xFF2196F3),
        foregroundColor: const Color.fromARGB(255, 255, 252, 221),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: 'Menu',
            onSelected: (value) {
              if (value == 'settings') {
                // Navigate to settings screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Cài đặt'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
  backgroundColor: const Color(0xFF2196F3),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Bài đọc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active),
            label: 'Nhắc lịch',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return _buildReadingsPage();
      case 2:
        return const VideosScreen();
      case 3:
        return const FavoritesScreen();
      case 4:
        return const ReminderScreen();
      default:
        return _buildHomePage();
    }
  }

  // Get 1 random daily reading from "Kinh tụng hàng ngày" category
  // Uses date-based seed to ensure same reading each day but different across days
  Sutra? _getDailyReading() {
    final dailyCategory = 'Kinh tụng hàng ngày';
    final sutrasInCategory = _dataService.getSutrasByCategory(dailyCategory);
    
    if (sutrasInCategory.isEmpty) {
      return null;
    }
    
    // Create a seed based on current date (year, month, day)
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);
    
    // Select one random sutra based on the date seed
    final index = random.nextInt(sutrasInCategory.length);
    return sutrasInCategory[index];
  }

  Widget _buildHomePage() {
    final dailyReading = _getDailyReading();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner with background image and top-down fade
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            height: 360,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image with safe fallback
                  Image.asset(
                    'assets/images/oar2.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(color: const Color(0xFFEFEFEF)),
                  ),

                  // Top-down white gradient (fade to transparent) so top is light
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFFFF), // fully white at top
                          Color(0x80FFFFFF), // semi-transparent white
                          Color(0x00FFFFFF), // transparent
                        ],
                        stops: [0.0, 0.25, 0.7],
                      ),
                    ),
                  ),

                  // Slight dark overlay at bottom for contrast (subtle)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.08)],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Texts positioned near the top (in the lightest area)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🙏Chào mừng quý phật tử!',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF333333),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đọc kinh mỗi ngày để tâm hồn thanh thản, an yên.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF333333),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Daily Reading Section
          Text(
            '📖 Bài đọc hằng ngày',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bài đọc được chọn ngẫu nhiên từ danh mục "Kinh tụng hàng ngày"',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          
          // Daily reading card
          if (dailyReading == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(Icons.library_books_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài đọc trong danh mục "Kinh tụng hàng ngày"',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SutraCard(
              sutra: dailyReading,
              onTap: () => _openSutraReading(dailyReading),
              onToggleFavorite: () => _toggleFavorite(dailyReading.id),
            ),
        ],
      ),
    );
  }

  Widget _buildReadingsPage() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: _showAudioOnly ? 'Tìm kiếm bài nghe...' : 'Tìm kiếm bài đọc...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _showAudioOnly
                  ? IconButton(
                      icon: const Icon(Icons.filter_alt, color: Colors.purple),
                      onPressed: () {
                        setState(() {
                          _showAudioOnly = false;
                        });
                      },
                      tooltip: 'Hiển thị tất cả bài đọc',
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Category filter
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: ['Tất cả', ..._dataService.getCategoryNames()].length,
            itemBuilder: (context, index) {
              final categories = ['Tất cả', ..._dataService.getCategoryNames()];
              final category = categories[index];
              final isSelected = category == _selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        ),
        
        // Readings list
        Expanded(
          child: _buildReadingsList(),
        ),
      ],
    );
  }

  Widget _buildReadingsList() {
    List<Sutra> filteredSutras = _dataService.sutras;
    
    // Filter by audio only if requested
    if (_showAudioOnly) {
      filteredSutras = filteredSutras.where((s) => s.hasAudio).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredSutras = _dataService.searchSutras(_searchQuery);
      if (_showAudioOnly) {
        filteredSutras = filteredSutras.where((s) => s.hasAudio).toList();
      }
    }
    
    // Filter by category
    if (_selectedCategory != 'Tất cả') {
      filteredSutras = _dataService.getSutrasByCategory(_selectedCategory);
      if (_showAudioOnly) {
        filteredSutras = filteredSutras.where((s) => s.hasAudio).toList();
      }
    }
    
    // Sort: favorites first
    filteredSutras.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return 0; // Keep original order for items with same favorite status
    });
    
    if (filteredSutras.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy kinh nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSutras.length,
      itemBuilder: (context, index) {
        final sutra = filteredSutras[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SutraCard(
            sutra: sutra,
            onTap: () => _openSutraReading(sutra),
            onToggleFavorite: () => _toggleFavorite(sutra.id),
          ),
        );
      },
    );
  }

  void _openSutraReading(Sutra sutra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SutraReadingScreen(sutra: sutra),
      ),
    );
  }

  void _toggleFavorite(String sutraId) async {
    await _dataService.toggleFavorite(sutraId);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_dataService.sutras.firstWhere((s) => s.id == sutraId).isFavorite
              ? 'Đã thêm vào yêu thích'
              : 'Đã bỏ yêu thích'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}