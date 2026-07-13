import 'package:flutter/material.dart';

import '../../features/library/domain/entities/track.dart';
import '../theme/studio_colors.dart';
import 'album_art.dart';

class TrackListTile extends StatelessWidget {
  const TrackListTile({
    super.key,
    required this.track,
    this.onTap,
    this.onPlay,
    this.trailing,
    this.showArt = true,
  });

  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final Widget? trailing;
  final bool showArt;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap ?? onPlay,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: showArt
          ? AlbumArt(
              artworkUrl: track.artworkUrl,
              artworkPath: track.artworkPath,
              size: 48,
            )
          : null,
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: StudioColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        track.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: StudioColors.silver),
      ),
      trailing: trailing ??
          (onPlay != null
              ? IconButton(
                  icon: const Icon(Icons.play_arrow_rounded),
                  color: StudioColors.white,
                  onPressed: onPlay,
                )
              : null),
    );
  }
}
