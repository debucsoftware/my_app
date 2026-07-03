import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Base64Image extends StatelessWidget {
  const Base64Image({
    super.key,
    required this.base64,
    this.height = 120,
    this.width,
    this.fit = BoxFit.cover,
    this.enlargeOnTap = true,
  });

  final String base64;
  final double height;
  final double? width;
  final BoxFit fit;
  final bool enlargeOnTap;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (!enlargeOnTap) return image;

    return GestureDetector(
      onTap: () => _showEnlarged(context),
      child: image,
    );
  }

  Widget _buildImage() {
    try {
      return Image.memory(
        base64Decode(base64),
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } catch (_) {
      return const Icon(Icons.broken_image);
    }
  }

  void _showEnlarged(BuildContext context) {
    Uint8List? bytes;
    try {
      bytes = base64Decode(base64);
    } catch (_) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: Image.memory(
                bytes!,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
