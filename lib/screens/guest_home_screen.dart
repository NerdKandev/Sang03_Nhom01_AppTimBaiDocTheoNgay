import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/sutra.dart';
import 'sutra_reading_screen.dart';
import '../widgets/sutra_card.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  int _currentIndex = 0;
  final DataService _dataService = DataService();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📿Đọc Kinh Hàng Ngày Đọc Kinh Hàng Ngày - Khách'),
  backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
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
            icon: Icon(Icons.menu_book),
            label: 'Đọc kinh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Nghe kinh',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Thông tin',
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
        return _buildAudioPage();
      case 3:
        return _buildInfoPage();
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
          // Welcome Card
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            elevation: 4,
            color: const Color(0xFF2196F3),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: const Color(0xFF2196F3), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Chào mừng Khách!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF2196F3),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Bạn đang sử dụng chế độ Khách. Bạn có thể đọc và nghe kinh Phật, nhưng không thể lưu yêu thích hoặc đánh dấu đã đọc.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          
          // Quick Stats
          Text(
            'Thống kê nhanh',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tổng số kinh',
                  _dataService.sutras.length.toString(),
                  Icons.library_books,
                  const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Danh mục',
                  _dataService.categories.length.toString(),
                  Icons.category,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Kinh dễ',
                  _dataService.sutras.where((s) => s.difficulty == 'Dễ').length.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Kinh khó',
                  _dataService.sutras.where((s) => s.difficulty == 'Khó').length.toString(),
                  Icons.star,
                  Colors.orange,
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                context: context,
                icon: Icons.menu_book,
                title: 'Đọc kinh',
                subtitle: 'Khám phá các kinh Phật',
                color: const Color(0xFF2196F3),
                onTap: () {
                  setState(() {
                    _currentIndex = 1; // Navigate to Readings tab
                  });
                },
              ),
              _buildFeatureCard(
                context: context,
                icon: Icons.headphones,
                title: 'Nghe kinh',
                subtitle: 'Nghe audio kinh Phật',
                color: Colors.green,
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Navigate to Audio tab
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
              hintText: 'Tìm kiếm kinh...',
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
        return SutraCard(
          sutra: sutra,
          onTap: () => _openSutraReading(sutra),
          onToggleFavorite: () => _showLoginRequired(),
        );
      },
    );
  }

  void _showLoginRequired() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng đăng nhập để lưu yêu thích.')),
    );
  }

  Widget _buildAudioPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.headphones, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chức năng nghe kinh',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Đang phát triển...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chế độ Khách',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Với chế độ Khách, bạn có thể:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Đọc tất cả các kinh Phật'),
                  const Text('• Nghe audio kinh (đang phát triển)'),
                  const Text('• Tìm kiếm kinh theo từ khóa'),
                  const Text('• Lọc kinh theo danh mục'),
                  const SizedBox(height: 16),
                  const Text(
                    'Hạn chế:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Không thể lưu yêu thích'),
                  const Text('• Không thể đánh dấu đã đọc'),
                  const Text('• Không thể tạo ghi chú'),
                  const SizedBox(height: 16),
                  const Text(
                    'Để sử dụng đầy đủ tính năng, vui lòng đăng ký tài khoản.',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin ứng dụng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Phiên bản: 1.0.0'),
                  const Text('Phát triển: Nhóm 01'),
                  const Text('Mục đích: Hỗ trợ đọc và học kinh Phật'),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
