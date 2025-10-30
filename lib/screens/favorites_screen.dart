import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/sutra.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final favoriteSutras = _dataService.getFavoriteSutras();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kinh Yêu Thích'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: favoriteSutras.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có kinh yêu thích nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hãy đánh dấu yêu thích các kinh bạn thích!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSutras.length,
              itemBuilder: (context, index) {
                final sutra = favoriteSutras[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(sutra.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sutra.titleVietnamese),
                        Text(sutra.description),
                        Row(
                          children: [
                            Chip(
                              label: Text(sutra.difficulty),
                              backgroundColor: _getDifficultyColor(sutra.difficulty),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(sutra.readingTime),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.favorite, color: Colors.red, size: 16),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        _dataService.toggleFavorite(sutra.id);
                        setState(() {});
                      },
                    ),
                    onTap: () {
                      _showSutraDetail(sutra);
                    },
                  ),
                );
              },
            ),
    );
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

  void _showSutraDetail(Sutra sutra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sutra.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tiếng Việt: ${sutra.titleVietnamese}'),
              Text('Pali: ${sutra.titlePali}'),
              const SizedBox(height: 16),
              Text('Mô tả: ${sutra.description}'),
              const SizedBox(height: 16),
              Text('Nội dung:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(sutra.fullContent),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _dataService.updateReadingCount(sutra.id);
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Đánh dấu đã đọc'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
