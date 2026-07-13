import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/studio_pill_button.dart';
import '../../../../core/widgets/track_list_tile.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../../player/presentation/pages/now_playing_page.dart';
import '../../presentation/bloc/discover_bloc.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch() {
    final q = _controller.text.trim();
    if (q.isEmpty) {
      context.read<DiscoverBloc>().add(const LoadPopular());
    } else {
      context.read<DiscoverBloc>().add(Search(q));
    }
  }

  void _clearSearch() {
    _controller.clear();
    context.read<DiscoverBloc>().add(const LoadPopular());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.canvas,
      body: Stack(
        children: [
          // Soft brand wash so glass blur actually reads.
          Positioned(
            top: -40,
            left: -60,
            child: _ColorBlob(
              color: StudioColors.brandMagenta.withValues(alpha: 0.22),
              size: 220,
            ),
          ),
          Positioned(
            top: 80,
            right: -40,
            child: _ColorBlob(
              color: StudioColors.brandCoral.withValues(alpha: 0.18),
              size: 180,
            ),
          ),
          Positioned(
            top: 200,
            left: 40,
            child: _ColorBlob(
              color: StudioColors.brandBlue.withValues(alpha: 0.12),
              size: 160,
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Text(
                    'Discover',
                    style: GoogleFonts.dmSans(
                      color: StudioColors.ink,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                  child: Text(
                    'Search free Jamendo tracks',
                    style: GoogleFonts.dmSans(
                      color: StudioColors.steel,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassPanel(
                          borderRadius: 28,
                          blur: 24,
                          tint: Colors.white.withValues(alpha: 0.55),
                          borderOpacity: 0.7,
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.search_rounded,
                                color: StudioColors.steel,
                                size: 22,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onChanged: (_) => setState(() {}),
                                  onSubmitted: (_) => _runSearch(),
                                  textInputAction: TextInputAction.search,
                                  style: GoogleFonts.dmSans(
                                    color: StudioColors.ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search Jamendo…',
                                    hintStyle: GoogleFonts.dmSans(
                                      color: StudioColors.stone,
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),
                              if (_controller.text.isNotEmpty)
                                _GlassIconButton(
                                  icon: Icons.close_rounded,
                                  onPressed: _clearSearch,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SearchButton(onPressed: _runSearch),
                    ],
                  ),
                ),
                Expanded(
                  child: BlocConsumer<DiscoverBloc, DiscoverState>(
                    listener: (context, state) {
                      if (state is DiscoverLoaded &&
                          state.downloadProgress >= 1 &&
                          state.savingTrackId == null) {
                        context
                            .read<LibraryBloc>()
                            .add(const RefreshLibrary());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Track saved to library'),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is DiscoverLoading) {
                        return Center(
                          child: state.downloadProgress > 0
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      value: state.downloadProgress,
                                      color: StudioColors.brandCoral,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${(state.downloadProgress * 100).round()}%',
                                      style: GoogleFonts.dmSans(
                                        color: StudioColors.steel,
                                      ),
                                    ),
                                  ],
                                )
                              : const CircularProgressIndicator(
                                  color: StudioColors.brandMagenta,
                                ),
                        );
                      }
                      if (state is DiscoverError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.dmSans(
                              color: StudioColors.error,
                            ),
                          ),
                        );
                      }
                      if (state is! DiscoverLoaded) {
                        return const SizedBox.shrink();
                      }
                      if (state.tracks.isEmpty) {
                        return Center(
                          child: Text(
                            'No results',
                            style: GoogleFonts.dmSans(
                              color: StudioColors.steel,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                        itemCount: state.tracks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final track = state.tracks[i];
                          final saving = state.savingTrackId == track.id;
                          final accent = [
                            StudioColors.brandCoral,
                            StudioColors.brandMagenta,
                            StudioColors.brandBlue,
                            StudioColors.brandPurple,
                          ][i % 4];
                          return GlassPanel(
                            borderRadius: 20,
                            blur: 16,
                            tint: Colors.white.withValues(alpha: 0.72),
                            padding: EdgeInsets.zero,
                            child: TrackListTile(
                              track: track,
                              onTap: () {
                                context.read<PlayerBloc>().add(Play(track));
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => BlocProvider.value(
                                      value: getIt<PlayerBloc>(),
                                      child: const NowPlayingPage(),
                                    ),
                                  ),
                                );
                              },
                              trailing: saving
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: accent,
                                          value: state.downloadProgress > 0
                                              ? state.downloadProgress
                                              : null,
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: StudioPillButton(
                                        label: 'Save',
                                        onPressed: () => context
                                            .read<DiscoverBloc>()
                                            .add(SaveTrack(track)),
                                      ),
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StudioColors.brandCoral,
      elevation: 0,
      borderRadius: BorderRadius.circular(999),
      shadowColor: StudioColors.brandCoral.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          child: Text(
            'Search',
            style: GoogleFonts.dmSans(
              color: StudioColors.onPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withValues(alpha: 0.45),
          shape: CircleBorder(
            side: BorderSide(
              color: StudioColors.hairline.withValues(alpha: 0.9),
            ),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: StudioColors.ink, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorBlob extends StatelessWidget {
  const _ColorBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
