import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../library/domain/entities/track.dart';
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
  });

  final List<Track> tracks;
  final String query;
  final double downloadProgress;
  final String? savingTrackId;

  DiscoverLoaded copyWith({
    List<Track>? tracks,
    String? query,
    double? downloadProgress,
    String? savingTrackId,
  }) {
    return DiscoverLoaded(
      tracks: tracks ?? this.tracks,
      query: query ?? this.query,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      savingTrackId: savingTrackId,
    );
  }

  @override
  List<Object?> get props => [tracks, query, downloadProgress, savingTrackId];
}

final class DiscoverError extends DiscoverState {
  const DiscoverError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
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

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc({
    required GetPopularDiscover getPopular,
    required SearchDiscover search,
    required SaveDiscoverTrack saveTrack,
  })  : _getPopular = getPopular,
        _search = search,
        _saveTrack = saveTrack,
        super(const DiscoverInitial()) {
    on<LoadPopular>(_onLoadPopular);
    on<Search>(_onSearch);
    on<SaveTrack>(_onSave);
  }

  final GetPopularDiscover _getPopular;
  final SearchDiscover _search;
  final SaveDiscoverTrack _saveTrack;

  Future<void> _onLoadPopular(
      LoadPopular event, Emitter<DiscoverState> emit) async {
    emit(const DiscoverLoading());
    try {
      final tracks = await _getPopular();
      emit(DiscoverLoaded(tracks: tracks, query: ''));
    } catch (e) {
      emit(DiscoverError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onSearch(Search event, Emitter<DiscoverState> emit) async {
    emit(const DiscoverLoading());
    try {
      final tracks = await _search(event.query);
      emit(DiscoverLoaded(tracks: tracks, query: event.query));
    } catch (e) {
      emit(DiscoverError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onSave(SaveTrack event, Emitter<DiscoverState> emit) async {
    final current = state;
    if (current is! DiscoverLoaded) return;
    emit(current.copyWith(savingTrackId: event.track.id, downloadProgress: 0));
    try {
      await _saveTrack(
        event.track,
        onProgress: (p) {
          final live = state;
          if (live is DiscoverLoaded) {
            emit(live.copyWith(downloadProgress: p));
          }
        },
      );
      final live = state;
      if (live is DiscoverLoaded) {
        emit(live.copyWith(savingTrackId: null, downloadProgress: 1));
      }
    } catch (e) {
      final live = state;
      if (live is DiscoverLoaded) {
        emit(live.copyWith(savingTrackId: null, downloadProgress: 0));
      } else {
        emit(DiscoverError(e is Failure ? e.message : e.toString()));
      }
    }
  }
}
