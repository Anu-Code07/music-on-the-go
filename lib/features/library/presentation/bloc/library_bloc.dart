import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/library_repository.dart';
import '../../domain/usecases/get_tracks.dart';
import '../../domain/usecases/import_track.dart';
import '../../domain/usecases/toggle_like.dart' as like_uc;

sealed class LibraryState extends Equatable {
  const LibraryState();
  @override
  List<Object?> get props => [];
}

final class LibraryInitial extends LibraryState {
  const LibraryInitial();
}

final class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

final class LibraryLoaded extends LibraryState {
  const LibraryLoaded({
    required this.tracks,
    required this.liked,
    required this.recents,
  });

  final List<Track> tracks;
  final List<Track> liked;
  final List<Track> recents;

  @override
  List<Object?> get props => [tracks, liked, recents];
}

final class LibraryError extends LibraryState {
  const LibraryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();
  @override
  List<Object?> get props => [];
}

final class LoadLibrary extends LibraryEvent {
  const LoadLibrary();
}

final class RefreshLibrary extends LibraryEvent {
  const RefreshLibrary();
}

final class ToggleLike extends LibraryEvent {
  const ToggleLike(this.trackId);
  final String trackId;
  @override
  List<Object?> get props => [trackId];
}

final class ImportFromDevice extends LibraryEvent {
  const ImportFromDevice();
}

final class DeleteTrack extends LibraryEvent {
  const DeleteTrack(this.trackId);
  final String trackId;
  @override
  List<Object?> get props => [trackId];
}

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({
    required GetTracks getTracks,
    required like_uc.ToggleLike toggleLike,
    required ImportTrack importTrack,
    required LibraryRepository library,
  })  : _getTracks = getTracks,
        _toggleLike = toggleLike,
        _importTrack = importTrack,
        _library = library,
        super(const LibraryInitial()) {
    on<LoadLibrary>(_onLoad);
    on<RefreshLibrary>(_onLoad);
    on<ToggleLike>(_onToggleLike);
    on<ImportFromDevice>(_onImport);
    on<DeleteTrack>(_onDelete);
  }

  final GetTracks _getTracks;
  final like_uc.ToggleLike _toggleLike;
  final ImportTrack _importTrack;
  final LibraryRepository _library;

  Future<void> _onLoad(LibraryEvent event, Emitter<LibraryState> emit) async {
    emit(const LibraryLoading());
    try {
      final tracks = await _getTracks();
      final liked = await _library.getLiked();
      final recents = await _library.getRecents();
      emit(LibraryLoaded(tracks: tracks, liked: liked, recents: recents));
    } catch (e) {
      emit(LibraryError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onToggleLike(
      ToggleLike event, Emitter<LibraryState> emit) async {
    try {
      await _toggleLike(event.trackId);
      add(const RefreshLibrary());
    } catch (e) {
      emit(LibraryError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onImport(
      ImportFromDevice event, Emitter<LibraryState> emit) async {
    try {
      await _importTrack();
      add(const RefreshLibrary());
    } catch (e) {
      if (e is Failure && e.message == 'Import cancelled') return;
      emit(LibraryError(e is Failure ? e.message : e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteTrack event, Emitter<LibraryState> emit) async {
    try {
      await _library.deleteTrack(event.trackId);
      add(const RefreshLibrary());
    } catch (e) {
      emit(LibraryError(e is Failure ? e.message : e.toString()));
    }
  }
}
