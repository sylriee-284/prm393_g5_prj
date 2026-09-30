import 'package:flutter/material.dart';

import '../models/comic.dart';

class ComicCover extends StatelessWidget {
  const ComicCover({
    super.key,
    required this.comic,
    this.width = 56,
    this.height = 76,
  });

  final Comic comic;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
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
      ),
    );
  }
}
