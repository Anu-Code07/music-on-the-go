import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_shell.dart';
import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/studio_pill_button.dart';
import '../../../../core/widgets/track_list_tile.dart';
import '../../../player/presentation/bloc/player_bloc.dart';
import '../../presentation/bloc/library_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        actions: [
          equalizerIconButton(context),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            onPressed: () =>
                context.read<LibraryBloc>().add(const ImportFromDevice()),
          ),
        ],
      ),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading || state is LibraryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LibraryError) {
            return Center(child: Text(state.message));
          }
          final tracks = (state as LibraryLoaded).tracks;
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No tracks yet', style: TextStyle(color: StudioColors.silver)),
                  const SizedBox(height: 16),
                  StudioPillButton(
                    label: 'Import from device',
                    icon: Icons.folder_open_rounded,
                    onPressed: () =>
                        context.read<LibraryBloc>().add(const ImportFromDevice()),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 140),
            itemCount: tracks.length,
            itemBuilder: (context, i) {
              final track = tracks[i];
              return TrackListTile(
                track: track,
                onPlay: () => context.read<PlayerBloc>().add(Play(track)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        track.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: track.isLiked
                            ? StudioColors.brandCoral
                            : StudioColors.steel,
                      ),
                      onPressed: () =>
                          context.read<LibraryBloc>().add(ToggleLike(track.id)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: StudioColors.silver),
                      onPressed: () =>
                          context.read<LibraryBloc>().add(DeleteTrack(track.id)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
