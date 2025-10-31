import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../models/sutra.dart';
import '../widgets/sutra_card.dart';
import 'sutra_reading_screen.dart';

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
        title: const Text('❤️ Bài Yêu Thích'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: const Color.fromARGB(255, 255, 252, 221),
      ),
      body: favoriteSutras.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bài yêu thích nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy đánh dấu yêu thích các bài bạn thích!',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSutras.length,
              itemBuilder: (context, index) {
                final sutra = favoriteSutras[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SutraCard(
                    sutra: sutra,
                    onTap: () => _openSutraReading(sutra),
                    onToggleFavorite: () => _toggleFavorite(sutra.id),
                  ),
                );
              },
            ),
    );
  }

  void _openSutraReading(Sutra sutra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SutraReadingScreen(sutra: sutra),
      ),
    ).then((_) {
      // Refresh favorites list when returning from reading screen
      setState(() {});
    });
  }

  void _toggleFavorite(String sutraId) async {
    await _dataService.toggleFavorite(sutraId);
    if (mounted) {
      setState(() {});
      final isStillFavorite = _dataService.sutras
          .firstWhere((s) => s.id == sutraId)
          .isFavorite;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isStillFavorite
              ? 'Đã thêm vào yêu thích'
              : 'Đã bỏ yêu thích'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}
