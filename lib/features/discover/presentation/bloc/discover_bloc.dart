import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../library/domain/entities/track.dart';
import '../../../library/domain/repositories/library_repository.dart';
import '../../domain/usecases/get_popular_discover.dart';
import '../../domain/usecases/save_discover_track.dart';
import '../../domain/usecases/search_discover.dart';

sealed class DiscoverState extends Equatable {
  const DiscoverState();
  @override
  List<Object?> get props => [];
}

final class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();
}

final class DiscoverLoading extends DiscoverState {
  const DiscoverLoading({this.downloadProgress = 0});
  final double downloadProgress;
  @override
  List<Object?> get props => [downloadProgress];
}

final class DiscoverLoaded extends DiscoverState {
  const DiscoverLoaded({
    required this.tracks,
    required this.query,
    this.downloadProgress = 0,
    this.savingTrackId,
    this.savedKeys = const {},
  });

  final List<Track> tracks;
  final String query;
  final double downloadProgress;
  final String? savingTrackId;

  /// Track ids / jamendo ids already present in the local library.
  final Set<String> savedKeys;

  bool isSaved(Track track) {
    if (savedKeys.contains(track.id)) return true;
    final jamendoId = track.jamendoId;
    if (jamendoId == null || jamendoId.isEmpty) return false;
    return savedKeys.contains(jamendoId) ||
        savedKeys.contains('jamendo_$jamendoId');
  }

  DiscoverLoaded copyWith({
    List<Track>? tracks,
    String? query,
    double? downloadProgress,
    Object? savingTrackId = _keep,
    Set<String>? savedKeys,
  }) {
    return DiscoverLoaded(
      tracks: tracks ?? this.tracks,
      query: query ?? this.query,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      savingTrackId: identical(savingTrackId, _keep)
          ? this.savingTrackId
          : savingTrackId as String?,
      savedKeys: savedKeys ?? this.savedKeys,
    );
  }

  @override
  List<Object?> get props =>
      [tracks, query, downloadProgress, savingTrackId, savedKeys];
}

const _keep = Object();

final class DiscoverError extends DiscoverState {
  const DiscoverError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

final class DiscoverSaveFailed extends DiscoverState {
  const DiscoverSaveFailed(
    this.message, {
    required this.tracks,
    required this.query,
    this.savedKeys = const {},
  });
  final String message;
  final List<Track> tracks;
  final String query;
  final Set<String> savedKeys;
  @override
  List<Object?> get props => [message, tracks, query, savedKeys];
}

sealed class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

final class LoadPopular extends DiscoverEvent {
  const LoadPopular();
}

final class Search extends DiscoverEvent {
  const Search(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

final class SaveTrack extends DiscoverEvent {
  const SaveTrack(this.track);
  final Track track;
  @override
  List<Object?> get props => [track];
}

final class RefreshSavedFlags extends DiscoverEvent {
  const RefreshSavedFlags();
}

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc({
    required GetPopularDiscover getPopular,
    required SearchDiscover search,
    required SaveDiscoverTrack saveTrack,
    required LibraryRepository library,
  })  : _getPopular = getPopular,
        _search = search,
        _saveTrack = saveTrack,
        _library = library,
        super(const DiscoverInitial()) {
    on<LoadPopular>(_onLoadPopular);
    on<Search>(_onSearch);
    on<SaveTrack>(_onSave);
    on<RefreshSavedFlags>(_onRefreshSaved);
  }

  final GetPopularDiscover _getPopular;
  final SearchDiscover _search;
  final SaveDiscoverTrack _saveTrack;
  final LibraryRepository _library;

  Future<Set<String>> _loadSavedKeys() async {
    final local = await _library.getTracks();
    final keys = <String>{};
    for (final track in local) {
      keys.add(track.id);
      final jamendoId = track.jamendoId;
      if (jamendoId != null && jamendoId.isNotEmpty) {
        keys.add(jamendoId);
        keys.add('jamendo_$jamendoId');
      }
    }
    return keys;
  }

  Future<void> _onLoadPopular(
      LoadPopular event, Emitter<DiscoverState> emit) async {
    emit(const DiscoverLoading());
    try {
      final results = await Future.wait([
        _getPopular(),
        _loadSavedKeys(),
      ]);
      final tracks = results[0] as List<Track>;
      final savedKeys = results[1] as Set<String>;
      emit(DiscoverLoaded(tracks: tracks, query: '', savedKeys: savedKeys));
    } catch (e) {
      emit(DiscoverError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onSearch(Search event, Emitter<DiscoverState> emit) async {
    emit(const DiscoverLoading());
    try {
      final results = await Future.wait([
        _search(event.query),
        _loadSavedKeys(),
      ]);
      final tracks = results[0] as List<Track>;
      final savedKeys = results[1] as Set<String>;
      emit(DiscoverLoaded(
        tracks: tracks,
        query: event.query,
        savedKeys: savedKeys,
      ));
    } catch (e) {
      emit(DiscoverError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onRefreshSaved(
      RefreshSavedFlags event, Emitter<DiscoverState> emit) async {
    final current = state;
    if (current is! DiscoverLoaded) return;
    try {
      final savedKeys = await _loadSavedKeys();
      emit(current.copyWith(savedKeys: savedKeys));
    } catch (_) {}
  }

  Future<void> _onSave(SaveTrack event, Emitter<DiscoverState> emit) async {
    final current = state;
    if (current is! DiscoverLoaded) return;
    if (current.savingTrackId != null) return;
    if (current.isSaved(event.track)) return;

    emit(current.copyWith(savingTrackId: event.track.id, downloadProgress: 0));
    try {
      final saved = await _saveTrack(
        event.track,
        onProgress: (p) {
          if (emit.isDone) return;
          final live = state;
          if (live is DiscoverLoaded &&
              live.savingTrackId == event.track.id) {
            emit(live.copyWith(downloadProgress: p.clamp(0.0, 1.0)));
          }
        },
      );
      if (emit.isDone) return;
      final live = state;
      if (live is DiscoverLoaded) {
        final keys = {
          ...live.savedKeys,
          saved.id,
          event.track.id,
          if (event.track.jamendoId != null &&
              event.track.jamendoId!.isNotEmpty) ...{
            event.track.jamendoId!,
            'jamendo_${event.track.jamendoId}',
          },
          if (saved.jamendoId != null && saved.jamendoId!.isNotEmpty) ...{
            saved.jamendoId!,
            'jamendo_${saved.jamendoId}',
          },
        };
        emit(live.copyWith(
          savingTrackId: null,
          downloadProgress: 0,
          savedKeys: keys,
        ));
      }
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      if (!emit.isDone) {
        emit(DiscoverSaveFailed(
          message,
          tracks: current.tracks,
          query: current.query,
          savedKeys: current.savedKeys,
        ));
        emit(DiscoverLoaded(
          tracks: current.tracks,
          query: current.query,
          savedKeys: current.savedKeys,
        ));
      }
    }
  }
}
