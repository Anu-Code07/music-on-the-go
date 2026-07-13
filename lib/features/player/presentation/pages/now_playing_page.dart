import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart' show LoopMode;

import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/album_art.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/now_playing_scrubber.dart';
import '../../../../core/widgets/studio_circular_play_button.dart';
import '../bloc/player_bloc.dart';

/// Full-screen immersive Now Playing — art-driven backdrop + glass controls.
class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  IconData _repeatIcon(LoopMode mode) => switch (mode) {
        LoopMode.one => Icons.repeat_one_rounded,
        LoopMode.all => Icons.repeat_rounded,
        _ => Icons.repeat_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.primary,
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is! PlayerReady || state.track == null) {
            return Center(
              child: Text(
                'Nothing playing',
                style: GoogleFonts.dmSans(color: StudioColors.onPrimary),
              ),
            );
          }
          final track = state.track!;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _ArtBackdrop(
                  artworkUrl: track.artworkUrl,
                  artworkPath: track.artworkPath,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          StudioColors.primary.withValues(alpha: 0.35),
                          StudioColors.primary.withValues(alpha: 0.55),
                          StudioColors.primary.withValues(alpha: 0.88),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final artSize =
                        (constraints.maxWidth - 72).clamp(220.0, 340.0);
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 32,
                                  color: StudioColors.onPrimary,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(
                                  'NOW PLAYING',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.dmSans(
                                    color: StudioColors.onPrimary
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2.5,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  state.isLiked
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: state.isLiked
                                      ? StudioColors.brandCoral
                                      : StudioColors.onPrimary,
                                ),
                                onPressed: () => context
                                    .read<PlayerBloc>()
                                    .add(const ToggleLikeCurrent()),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 1),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: AlbumArt(
                            artworkUrl: track.artworkUrl,
                            artworkPath: track.artworkPath,
                            heroTag: 'now_${track.id}',
                            size: artSize,
                            borderRadius: 32,
                          ),
                        ),
                        const Spacer(flex: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              Text(
                                track.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  color: StudioColors.onPrimary,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                track.artist,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  color: StudioColors.onPrimary
                                      .withValues(alpha: 0.72),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                          child: GlassPanel(
                            borderRadius: 28,
                            blur: 28,
                            tint: Colors.white.withValues(alpha: 0.12),
                            borderOpacity: 0.35,
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                sliderTheme: SliderThemeData(
                                  activeTrackColor: StudioColors.onPrimary,
                                  inactiveTrackColor: StudioColors.onPrimary
                                      .withValues(alpha: 0.25),
                                  thumbColor: StudioColors.onPrimary,
                                  overlayColor: StudioColors.onPrimary
                                      .withValues(alpha: 0.12),
                                ),
                                iconTheme: const IconThemeData(
                                  color: StudioColors.onPrimary,
                                ),
                              ),
                              child: Column(
                                children: [
                                  NowPlayingScrubber(
                                    position: state.position,
                                    duration: state.duration,
                                    onSeek: (d) => context
                                        .read<PlayerBloc>()
                                        .add(Seek(d)),
                                    lightLabels: true,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.shuffle_rounded,
                                          color: state.shuffle
                                              ? StudioColors.brandCoral
                                              : StudioColors.onPrimary
                                                  .withValues(alpha: 0.65),
                                        ),
                                        onPressed: () => context
                                            .read<PlayerBloc>()
                                            .add(const ToggleShuffle()),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.skip_previous_rounded,
                                          size: 40,
                                          color: StudioColors.onPrimary,
                                        ),
                                        onPressed: () => context
                                            .read<PlayerBloc>()
                                            .add(const Previous()),
                                      ),
                                      StudioCircularPlayButton(
                                        isPlaying: state.isPlaying,
                                        size: 72,
                                        onPressed: () => context
                                            .read<PlayerBloc>()
                                            .add(const Toggle()),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.skip_next_rounded,
                                          size: 40,
                                          color: StudioColors.onPrimary,
                                        ),
                                        onPressed: () => context
                                            .read<PlayerBloc>()
                                            .add(const Next()),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          _repeatIcon(state.repeat),
                                          color: state.repeat == LoopMode.off
                                              ? StudioColors.onPrimary
                                                  .withValues(alpha: 0.65)
                                              : StudioColors.brandCoral,
                                        ),
                                        onPressed: () => context
                                            .read<PlayerBloc>()
                                            .add(const ToggleRepeat()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArtBackdrop extends StatelessWidget {
  const _ArtBackdrop({this.artworkUrl, this.artworkPath});

  final String? artworkUrl;
  final String? artworkPath;

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (artworkPath != null && artworkPath!.isNotEmpty) {
      final file = File(artworkPath!);
      image = file.existsSync()
          ? Image.file(file, fit: BoxFit.cover)
          : const ColoredBox(color: StudioColors.primary);
    } else if (artworkUrl != null && artworkUrl!.isNotEmpty) {
      image = CachedNetworkImage(
        imageUrl: artworkUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) =>
            const ColoredBox(color: StudioColors.primary),
      );
    } else {
      image = const ColoredBox(color: StudioColors.primary);
    }
    return SizedBox.expand(child: image);
  }
}
