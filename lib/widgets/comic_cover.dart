import 'package:flutter/material.dart';

import '../models/comic.dart';

class ComicCover extends StatelessWidget {
  const ComicCover({
    super.key,
    required this.comic,
    this.width = 56,
    this.height = 76,
    this.borderRadius = 6,
  });

  final Comic comic;
  final double width;
  final double height;
  final double borderRadius;

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: Color(comic.coverColor),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(6),
      child: Text(
        comic.coverLabel,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: comic.coverUrl.trim().isNotEmpty
            ? Image.network(
                comic.coverUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }
}
