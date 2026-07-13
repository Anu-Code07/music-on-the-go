import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/discover/presentation/bloc/discover_bloc.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/equalizer/presentation/bloc/equalizer_bloc.dart';
import '../../features/equalizer/presentation/pages/equalizer_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/library/presentation/bloc/library_bloc.dart';
import '../../features/library/presentation/pages/library_page.dart';
import '../../features/player/presentation/bloc/player_bloc.dart';
import '../../features/player/presentation/pages/now_playing_page.dart';
import '../../features/playlist/presentation/bloc/playlist_bloc.dart';
import '../../features/playlist/presentation/pages/playlists_page.dart';
import '../di/injection.dart';
import '../theme/studio_colors.dart';
import '../widgets/glass_panel.dart';
import '../widgets/mini_player_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void goToTab(int index) {
    if (index < 0 || index > 3) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<LibraryBloc>()..add(const LoadLibrary()),
        ),
        BlocProvider(
          create: (_) => getIt<PlaylistBloc>()..add(const LoadPlaylists()),
        ),
        BlocProvider(
          create: (_) {
            final bloc = getIt<DiscoverBloc>();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(const LoadPopular());
            });
            return bloc;
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: StudioColors.canvas,
            extendBody: true,
            body: Stack(
              children: [
                Positioned.fill(
                  child: IndexedStack(
                    index: _index,
                    children: const [
                      HomePage(),
                      DiscoverPage(),
                      LibraryPage(),
                      PlaylistsPage(),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MiniPlayerBar(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider.value(
                              value: getIt<PlayerBloc>(),
                              child: const NowPlayingPage(),
                            ),
                          ),
                        ),
                      ),
                      GlassDock(
                        child: SafeArea(
                          top: false,
                          child: BottomNavigationBar(
                            currentIndex: _index,
                            onTap: (i) => setState(() => _index = i),
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            type: BottomNavigationBarType.fixed,
                            selectedItemColor: StudioColors.ink,
                            unselectedItemColor: StudioColors.steel,
                            items: const [
                              BottomNavigationBarItem(
                                icon: Icon(Icons.home_rounded),
                                label: 'Home',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.explore_rounded),
                                label: 'Discover',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.library_music_rounded),
                                label: 'Library',
                              ),
                              BottomNavigationBarItem(
                                icon: Icon(Icons.queue_music_rounded),
                                label: 'Playlists',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void goToShellTab(BuildContext context, int index) {
  context.findAncestorStateOfType<_AppShellState>()?.goToTab(index);
}

void openEqualizer(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => getIt<EqualizerBloc>()..add(const LoadPresets()),
        child: const EqualizerPage(),
      ),
    ),
  );
}

Widget equalizerIconButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Material(
      color: StudioColors.canvas,
      shape: const CircleBorder(
        side: BorderSide(color: StudioColors.hairline),
      ),
      child: IconButton(
        icon: const Icon(Icons.graphic_eq_rounded, color: StudioColors.ink),
        tooltip: 'Equalizer',
        onPressed: () => openEqualizer(context),
      ),
    ),
  );
}
