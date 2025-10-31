import 'package:flutter/material.dart';
import '../models/sutra.dart';

class SutraCard extends StatelessWidget {
  final Sutra sutra;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;

  const SutraCard({
    super.key,
    required this.sutra,
    this.onTap,
    this.onToggleFavorite,
  });

  Widget _buildImageWidget() {
    String imagePath = sutra.coverImage?.trim() ?? 'assets/images/placeholder.jpg';
    
    // Ensure not empty
    if (imagePath.isEmpty) {
      imagePath = 'assets/images/placeholder.jpg';
    }
    
    return Image.asset(
      imagePath,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        print('SutraCard: Failed to load image: $imagePath');
        // If the specified image fails, try placeholder
        if (imagePath != 'assets/images/placeholder.jpg') {
          return Image.asset(
            'assets/images/placeholder.jpg',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error2, stack2) {
              print('SutraCard: Placeholder also failed');
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              );
            },
          );
        }
        // If placeholder also fails, show error icon
        return Container(
          width: 80,
          height: 80,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, color: Colors.grey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sutra.titleVietnamese,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Favorite icon button
                        IconButton(
                          icon: Icon(
                            sutra.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: sutra.isFavorite ? Colors.red : Colors.grey,
                            size: 24,
                          ),
                          onPressed: () {
                            onToggleFavorite?.call();
                          },
                          tooltip: sutra.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sutra.title,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(sutra.category, style: const TextStyle(fontSize: 12))),
                        if (sutra.isFavorite)
                          Chip(
                            label: const Text('Yêu thích bài đọc', style: TextStyle(fontSize: 12)),
                            backgroundColor: Colors.red[100],
                            labelStyle: TextStyle(color: Colors.red[800]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
