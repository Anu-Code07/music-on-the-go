import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/studio_pill_button.dart';
import '../../presentation/bloc/playlist_bloc.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          if (state is PlaylistLoading || state is PlaylistInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlaylistError) {
            return Center(child: Text(state.message));
          }
          final playlists = (state as PlaylistLoaded).playlists;
          if (playlists.isEmpty) {
            return Center(
              child: StudioPillButton(
                label: 'Create your first playlist',
                icon: Icons.add,
                onPressed: () => _createDialog(context),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 140),
            itemCount: playlists.length,
            itemBuilder: (context, i) {
              final p = playlists[i];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: StudioColors.midCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.queue_music, color: StudioColors.silver),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${p.trackIds.length} tracks'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: StudioColors.silver),
                  onPressed: () => context.read<PlaylistBloc>().add(Delete(p.id)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: StudioColors.primary,
        onPressed: () => _createDialog(context),
        child: const Icon(Icons.add, color: StudioColors.onPrimary),
      ),
    );
  }

  Future<void> _createDialog(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
