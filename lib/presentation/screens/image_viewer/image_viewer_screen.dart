import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImageViewerScreen extends StatelessWidget {
  final String url;
  final String title;
  
  const ImageViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black45,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: CachedNetworkImageProvider(url),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 4,
        heroAttributes: PhotoViewHeroAttributes(tag: url),
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
            color: const Color(0xFF6C63FF),
          ),
        ),
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
