import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../../features/discover/data/datasources/jamendo_data_source.dart';
import '../../features/discover/data/datasources/theaudiodb_data_source.dart';
import '../../features/discover/data/repositories/discover_repository_impl.dart';
import '../../features/discover/domain/repositories/discover_repository.dart';
import '../../features/discover/domain/usecases/get_popular_discover.dart';
import '../../features/discover/domain/usecases/save_discover_track.dart';
import '../../features/discover/domain/usecases/search_discover.dart';
import '../../features/discover/presentation/bloc/discover_bloc.dart';
import '../../features/equalizer/data/datasources/equalizer_data_source.dart';
import '../../features/equalizer/presentation/bloc/equalizer_bloc.dart';
import '../../features/library/data/datasources/local_library_data_source.dart';
import '../../features/library/data/datasources/seed_library_bootstrap.dart';
import '../../features/library/data/repositories/library_repository_impl.dart';
import '../../features/library/domain/repositories/library_repository.dart';
import '../../features/library/domain/usecases/ensure_seed_library.dart';
import '../../features/library/domain/usecases/get_tracks.dart';
import '../../features/library/domain/usecases/import_track.dart';
import '../../features/library/domain/usecases/toggle_like.dart' as library_uc;
import '../../features/library/presentation/bloc/library_bloc.dart';
import '../../features/player/data/datasources/audio_player_data_source.dart';
import '../../features/player/data/datasources/widget_bridge_data_source.dart';
import '../../features/player/domain/usecases/play_track.dart';
import '../../features/player/domain/usecases/toggle_play_pause.dart';
import '../../features/player/presentation/bloc/player_bloc.dart';
import '../../features/playlist/data/repositories/playlist_repository_impl.dart';
import '../../features/playlist/domain/repositories/playlist_repository.dart';
import '../../features/playlist/domain/usecases/add_track_to_playlist.dart';
import '../../features/playlist/domain/usecases/create_playlist.dart';
import '../../features/playlist/domain/usecases/get_playlists.dart';
import '../../features/playlist/presentation/bloc/playlist_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<Dio>()) return;

  getIt.registerLazySingleton<Dio>(() => Dio());

  getIt.registerLazySingleton<LocalLibraryDataSource>(
    LocalLibraryDataSource.new,
  );
  getIt.registerLazySingleton<SeedLibraryBootstrap>(
    () => SeedLibraryBootstrap(getIt()),
  );

  getIt.registerLazySingleton<JamendoDataSource>(
    () => JamendoDataSource(dio: getIt()),
  );
  getIt.registerLazySingleton<TheAudioDbDataSource>(
    () => TheAudioDbDataSource(dio: getIt()),
  );
  getIt.registerLazySingleton<WidgetBridgeDataSource>(
    WidgetBridgeDataSource.new,
  );

  // Plain player — AndroidEqualizer was hanging startup on some emulators.
  getIt.registerLazySingleton<AudioPlayer>(AudioPlayer.new);
  getIt.registerLazySingleton<AudioPlayerDataSource>(
    () => AudioPlayerDataSource(getIt()),
  );
  getIt.registerLazySingleton<EqualizerDataSource>(
    () => EqualizerDataSource(getIt(), null),
  );

  getIt.registerLazySingleton<LibraryRepository>(
    () => LibraryRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<DiscoverRepository>(
    () => DiscoverRepositoryImpl(getIt(), getIt(), getIt()),
  );

  getIt.registerFactory(() => GetTracks(getIt()));
  getIt.registerFactory(() => library_uc.ToggleLike(getIt()));
  getIt.registerFactory(() => ImportTrack(getIt()));
  getIt.registerFactory(() => EnsureSeedLibrary(getIt()));
  getIt.registerFactory(() => GetPlaylists(getIt()));
  getIt.registerFactory(() => CreatePlaylist(getIt()));
  getIt.registerFactory(() => AddTrackToPlaylist(getIt()));
  getIt.registerFactory(() => SearchDiscover(getIt()));
  getIt.registerFactory(() => SaveDiscoverTrack(getIt()));
  getIt.registerFactory(() => GetPopularDiscover(getIt()));
  getIt.registerFactory(() => PlayTrack(getIt(), getIt()));
  getIt.registerFactory(() => TogglePlayPause(getIt()));

  getIt.registerLazySingleton<PlayerBloc>(
    () => PlayerBloc(
      audio: getIt(),
      playTrack: getIt(),
      togglePlayPause: getIt(),
      toggleLike: getIt(),
      library: getIt(),
      widgetBridge: getIt(),
    ),
  );
  getIt.registerFactory(
    () => LibraryBloc(
      getTracks: getIt(),
      toggleLike: getIt(),
      importTrack: getIt(),
      library: getIt(),
    ),
  );
  getIt.registerFactory(
    () => PlaylistBloc(
      getPlaylists: getIt(),
      createPlaylist: getIt(),
      addTrack: getIt(),
      repository: getIt(),
    ),
  );
  getIt.registerFactory(
    () => DiscoverBloc(
      getPopular: getIt(),
      search: getIt(),
      saveTrack: getIt(),
      library: getIt(),
    ),
  );
  getIt.registerFactory(() => EqualizerBloc(getIt()));
  // EQ init is optional and must not block boot.
}

