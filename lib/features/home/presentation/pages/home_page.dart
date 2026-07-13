import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_shell.dart';
import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/album_art.dart';
import '../../../../core/widgets/product_identity_card.dart';
import '../../../../core/widgets/studio_pill_button.dart';
import '../../../discover/presentation/bloc/discover_bloc.dart';
import '../../../library/domain/entities/track.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../../player/presentation/pages/now_playing_page.dart';
import '../../../playlist/presentation/bloc/playlist_bloc.dart';
import '../../../../core/di/injection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.canvas,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _HeroHeader(greeting: _greeting())),
            const SliverToBoxAdapter(child: _QuickMatrix()),
            SliverToBoxAdapter(child: _sectionLabel('Recently played')),
            const SliverToBoxAdapter(child: _RecentsRail()),
            SliverToBoxAdapter(child: _sectionLabel('Discover')),
            const SliverToBoxAdapter(child: _DiscoverMatrix()),
            SliverToBoxAdapter(child: _sectionLabel('Liked songs')),
            const SliverToBoxAdapter(child: _LikedRail()),
            SliverToBoxAdapter(child: _sectionLabel('Your playlists')),
            const SliverToBoxAdapter(child: _PlaylistChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 160)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 14),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          color: StudioColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARIA',
                  style: GoogleFonts.dmSans(
                    color: StudioColors.stone,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  greeting,
                  style: GoogleFonts.dmSans(
                    color: StudioColors.ink,
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Local library. Offline first.',
                  style: GoogleFonts.dmSans(
                    color: StudioColors.steel,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          equalizerIconButton(context),
        ],
      ),
    );
  }
}

class _QuickMatrix extends StatelessWidget {
  const _QuickMatrix();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        children: [
          ProductIdentityCard(
            title: 'Music',
            subtitle: 'Discover free tracks',
            color: StudioColors.brandMagenta,
            badge: 'LIVE',
            width: 150,
            height: 160,
            onTap: () => goToShellTab(context, 1),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.graphic_eq_rounded,
                  color: Colors.white70, size: 36),
            ),
          ),
          const SizedBox(width: 12),
          ProductIdentityCard(
            title: 'Library',
            subtitle: 'Saved offline',
            color: StudioColors.brandCoral,
            width: 150,
            height: 160,
            onTap: () => goToShellTab(context, 2),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.library_music_rounded,
                  color: Colors.white70, size: 36),
            ),
          ),
          const SizedBox(width: 12),
          ProductIdentityCard(
            title: 'EQ',
            subtitle: 'Tune your sound',
            color: StudioColors.brandBlue,
            width: 150,
            height: 160,
            onTap: () => openEqualizer(context),
            child: const Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.tune_rounded, color: Colors.white70, size: 36),
            ),
          ),
          const SizedBox(width: 12),
          ProductIdentityCard(
            title: 'Liked',
            subtitle: 'Your favorites',
            color: StudioColors.brandPurple,
            width: 150,
            height: 160,
            onTap: () => goToShellTab(context, 2),
            child: const Align(
              alignment: Alignment.topLeft,
              child:
                  Icon(Icons.favorite_rounded, color: Colors.white70, size: 36),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentsRail extends StatelessWidget {
  const _RecentsRail();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final recents = state is LibraryLoaded ? state.recents : <Track>[];
        if (recents.isEmpty) {
          return const _EmptyHint('Play something to see recents');
        }
        return _TrackRail(tracks: recents);
      },
    );
  }
}

class _LikedRail extends StatelessWidget {
  const _LikedRail();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final liked = state is LibraryLoaded ? state.liked : <Track>[];
        if (liked.isEmpty) {
          return const _EmptyHint('No liked tracks yet');
        }
        return _TrackRail(tracks: liked);
      },
    );
  }
}

class _DiscoverMatrix extends StatelessWidget {
  const _DiscoverMatrix();

  static const _accents = [
    StudioColors.brandCoral,
    StudioColors.brandMagenta,
    StudioColors.brandBlue,
    StudioColors.brandPurple,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        final tracks = state is DiscoverLoaded
            ? state.tracks.take(8).toList()
            : <Track>[];
        if (tracks.isEmpty) {
          return const _EmptyHint('Loading discover…');
        }
        return SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final track = tracks[i];
              final accent = _accents[i % _accents.length];
              return ProductIdentityCard(
                title: track.title,
                subtitle: track.artist,
                color: accent,
                width: 168,
                height: 210,
                badge: i == 0 ? 'NEW' : null,
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
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: AlbumArt(
                      artworkUrl: track.artworkUrl,
                      artworkPath: track.artworkPath,
                      size: 64,
                      borderRadius: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TrackRail extends StatelessWidget {
  const _TrackRail({required this.tracks});
  final List<Track> tracks;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: tracks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _QuietTrackCard(track: tracks[i]),
      ),
    );
  }
}

class _QuietTrackCard extends StatelessWidget {
  const _QuietTrackCard({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: Container(
        width: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StudioColors.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StudioColors.hairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AlbumArt(
              artworkUrl: track.artworkUrl,
              artworkPath: track.artworkPath,
              size: 108,
              borderRadius: 12,
            ),
            const SizedBox(height: 10),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                color: StudioColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
    );
  }
}

class _PlaylistChips extends StatelessWidget {
  const _PlaylistChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        final playlists = state is PlaylistLoaded ? state.playlists : [];
        if (playlists.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StudioPillButton(
              label: 'Create playlist',
              icon: Icons.add,
              onPressed: () => _createPlaylistDialog(context),
            ),
          );
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              for (final p in playlists)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: StudioPillButton(
                    label: p.name,
                    filled: false,
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createPlaylistDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      context.read<PlaylistBloc>().add(Create(name));
    }
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: StudioColors.surface.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: StudioColors.hairline),
            ),
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                color: StudioColors.steel,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
