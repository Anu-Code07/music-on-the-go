import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/player/presentation/bloc/player_bloc.dart';
import '../theme/studio_colors.dart';
import 'album_art.dart';
import 'glass_panel.dart';
import 'studio_circular_play_button.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        if (state is! PlayerReady || state.track == null) {
          return const SizedBox.shrink();
        }
        final track = state.track!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: GlassPanel(
            borderRadius: 20,
            blur: 24,
            padding: EdgeInsets.zero,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      AlbumArt(
                        artworkUrl: track.artworkUrl,
                        artworkPath: track.artworkPath,
                        heroTag: 'mini_${track.id}',
                        size: 48,
                        borderRadius: 12,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: StudioColors.ink,
                              ),
                            ),
                            Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                color: StudioColors.steel,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StudioCircularPlayButton(
                        isPlaying: state.isPlaying,
                        onPressed: () =>
                            context.read<PlayerBloc>().add(const Toggle()),
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
