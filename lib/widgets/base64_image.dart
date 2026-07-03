import 'dart:convert';

import 'package:flutter/material.dart';

class Base64Image extends StatelessWidget {
  const Base64Image({
    super.key,
    required this.base64,
    this.height = 120,
    this.width,
    this.fit = BoxFit.cover,
  });

  final String base64;
  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
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
}
