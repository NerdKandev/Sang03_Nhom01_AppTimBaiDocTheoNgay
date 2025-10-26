import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../widgets/sutra_card.dart';
import '../models/sutra.dart';
import 'sutra_reading_screen.dart';
import 'admin_user_management_screen.dart';
import 'settings_screen.dart';

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
  Set<int> _favoriteReadings = {};
  Set<int> _readReadings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📿 Đọc Kinh Hàng Ngày'),
  backgroundColor: const Color(0xFF2196F3),
        foregroundColor: const Color.fromARGB(255, 255, 252, 221),
        actions: [
          // Admin User Management Button (for demo purposes, always show)
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUserManagementScreen(),
                ),
              );
            },
            tooltip: 'Quản lý người dùng',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Đăng xuất',
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
            icon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Đã đọc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
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
        return _buildFavoritesPage();
      case 3:
        return _buildHistoryPage();
      case 4:
        return _buildSettingsPage();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // (welcoming text card removed - now only the image banner remains)
          
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
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Kinh yêu thích',
                  _dataService.sutras.where((s) => s.isFavorite).length.toString(),
                  Icons.favorite,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Tổng lần đọc',
                  _dataService.sutras.fold(0, (sum, s) => sum + s.readingCount).toString(),
                  Icons.note,
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            'Thao tác nhanh',
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
  color: const Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildQuickActionCard(
                'Đọc hôm nay',
                Icons.today,
                const Color(0xFF2196F3),
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
              _buildQuickActionCard(
                'Tìm kiếm',
                Icons.search,
                Colors.green,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
              _buildQuickActionCard(
                'Lịch đọc',
                Icons.calendar_today,
                Colors.orange,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
              _buildQuickActionCard(
                'Thống kê',
                Icons.analytics,
                Colors.purple,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chức năng đang phát triển')),
                  );
                },
              ),
            ],
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
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm bài đọc...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
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
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredSutras = _dataService.searchSutras(_searchQuery);
    }
    
    // Filter by category
    if (_selectedCategory != 'Tất cả') {
      filteredSutras = _dataService.getSutrasByCategory(_selectedCategory);
    }
    
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

  void _toggleFavorite(String sutraId) {
    setState(() {
      _dataService.toggleFavorite(sutraId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật yêu thích')),
      );
    });
  }

  void _markAsRead(String sutraId) {
    setState(() {
      _dataService.updateReadingCount(sutraId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu đã đọc')),
      );
    });
  }

  void _openSutraReading(Sutra sutra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SutraReadingScreen(sutra: sutra),
      ),
    );
  }

  Widget _buildFavoritesPage() {
    final favoriteSutras = _dataService.sutras
        .where((sutra) => sutra.isFavorite)
        .toList();

    if (favoriteSutras.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có kinh yêu thích nào',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy thêm kinh vào yêu thích!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteSutras.length,
      itemBuilder: (context, index) {
        final sutra = favoriteSutras[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(sutra.titleVietnamese),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sutra.title),
                Text('${sutra.category} - ${sutra.difficulty}'),
                const SizedBox(height: 8),
                Text(
                  sutra.description.length > 100 
                      ? '${sutra.description.substring(0, 100)}...'
                      : sutra.description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => _toggleFavorite(sutra.id),
              tooltip: 'Bỏ yêu thích',
            ),
            onTap: () => _openSutraReading(sutra),
          ),
        );
      },
    );
  }

  Widget _buildHistoryPage() {
    final readSutras = _dataService.getRecentlyReadSutras();

    if (readSutras.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có kinh nào được đánh dấu',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Hãy đánh dấu kinh đã đọc!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: readSutras.length,
      itemBuilder: (context, index) {
        final sutra = readSutras[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(sutra.titleVietnamese),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sutra.title),
                Text('${sutra.category} - ${sutra.difficulty}'),
                Text('Đã đọc: ${sutra.readingCount} lần'),
                if (sutra.lastRead != null)
                  Text('Lần cuối: ${sutra.lastRead}'),
                const SizedBox(height: 8),
                Text(
                  sutra.description.length > 100 
                      ? '${sutra.description.substring(0, 100)}...'
                      : sutra.description,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _markAsRead(sutra.id),
              tooltip: 'Đánh dấu đã đọc',
            ),
            onTap: () => _openSutraReading(sutra),
          ),
        );
      },
    );
  }

  Widget _buildSettingsPage() {
    return const SettingsScreen();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return Colors.green.withOpacity(0.2);
      case 'Trung bình':
        return Colors.orange.withOpacity(0.2);
      case 'Khó':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}