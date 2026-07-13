import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/studio_colors.dart';
import '../../../../core/widgets/studio_pill_button.dart';
import '../../../../core/widgets/track_list_tile.dart';
import '../../../library/presentation/bloc/library_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search Jamendo…',
                prefixIcon: const Icon(Icons.search, color: StudioColors.silver),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: StudioColors.silver),
                  onPressed: () {
                    _controller.clear();
                    context.read<DiscoverBloc>().add(const LoadPopular());
                  },
                ),
              ),
              onSubmitted: (q) => context.read<DiscoverBloc>().add(Search(q)),
            ),
          ),
          Expanded(
            child: BlocConsumer<DiscoverBloc, DiscoverState>(
              listener: (context, state) {
                if (state is DiscoverLoaded &&
                    state.downloadProgress >= 1 &&
                    state.savingTrackId == null) {
                  context.read<LibraryBloc>().add(const RefreshLibrary());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Track saved to library')),
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
                              CircularProgressIndicator(value: state.downloadProgress),
                              const SizedBox(height: 12),
                              Text('${(state.downloadProgress * 100).round()}%'),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  );
                }
                if (state is DiscoverError) {
                  return Center(child: Text(state.message));
                }
                if (state is! DiscoverLoaded) {
                  return const SizedBox.shrink();
                }
                if (state.tracks.isEmpty) {
                  return const Center(
                    child: Text('No results', style: TextStyle(color: StudioColors.silver)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 140),
                  itemCount: state.tracks.length,
                  itemBuilder: (context, i) {
                    final track = state.tracks[i];
                    final saving = state.savingTrackId == track.id;
                    return TrackListTile(
                      track: track,
                      trailing: saving
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                value: state.downloadProgress > 0
                                    ? state.downloadProgress
                                    : null,
                              ),
                            )
                          : StudioPillButton(
                              label: 'Save',
                              filled: false,
                              onPressed: () =>
                                  context.read<DiscoverBloc>().add(SaveTrack(track)),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
