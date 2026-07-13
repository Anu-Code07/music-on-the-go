import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/studio_colors.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    this.artworkUrl,
    this.artworkPath,
    this.assetPath,
    this.heroTag,
    this.size = 56,
    this.borderRadius = 8,
  });

  final String? artworkUrl;
  final String? artworkPath;
  final String? assetPath;
  final Object? heroTag;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    final clipped = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: size, height: size, child: image),
    );
    if (heroTag != null) {
      return Hero(tag: heroTag!, child: clipped);
    }
    return clipped;
  }

  Widget _buildImage() {
    if (artworkPath != null && artworkPath!.isNotEmpty) {
      final file = File(artworkPath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(assetPath!, fit: BoxFit.cover);
    }
    if (artworkUrl != null && artworkUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: artworkUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: StudioColors.midCard,
      child: Icon(Icons.music_note, color: StudioColors.silver, size: size * 0.45),
    );
  }
}
