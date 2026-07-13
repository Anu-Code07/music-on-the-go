import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/library/domain/entities/track.dart';
import '../../features/player/presentation/bloc/player_bloc.dart';
import '../../features/player/presentation/pages/now_playing_page.dart';
import '../di/injection.dart';

/// Wait for play to start before opening Now Playing (avoids "Nothing playing").
Future<void> playAndOpenNowPlaying(BuildContext context, Track track) async {
  final player = getIt<PlayerBloc>();
  player.add(Play(track));

  // Give the async Play handler a moment to set the source.
  for (var i = 0; i < 40; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final state = player.state;
    if (state is PlayerReady && state.track != null) break;
  }

  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: player,
        child: const NowPlayingPage(),
      ),
    ),
  );
}
