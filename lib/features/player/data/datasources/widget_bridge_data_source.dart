import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';
import 'package:live_activities/models/url_scheme_data.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../library/domain/entities/track.dart';

/// Remote / Live Activity control actions.
enum RemotePlayerAction { play, pause, toggle, next, previous }

class WidgetBridgeDataSource {
  WidgetBridgeDataSource();

  static const appGroupId = 'group.com.anurag.studio';
  static const androidWidgetName = 'StudioPlayerWidget';
  static const iosWidgetName = 'StudioPlayerWidget';
  static const liveActivityId = 'aria_now_playing';

  static const _nowPlayingChannel =
      MethodChannel('com.anurag.studio/now_playing');
  static const _remoteCommandsChannel =
      MethodChannel('com.anurag.studio/remote_commands');

  final LiveActivities _liveActivities = LiveActivities();
  final _remoteActions = StreamController<RemotePlayerAction>.broadcast();

  StreamSubscription<UrlSchemeData>? _urlSub;

  bool _initialized = false;
  bool _activityActive = false;
  DateTime? _lastLiveUpdate;
  String? _lastTrackId;
  bool? _lastPlaying;

  Stream<RemotePlayerAction> get remoteActions => _remoteActions.stream;

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('HomeWidget app group: $e');
    }
    try {
      await _liveActivities.init(
        appGroupId: appGroupId,
        urlScheme: 'aria',
      );
      _urlSub = _liveActivities.urlSchemeStream().listen(_onUrlScheme);
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      debugPrint('LiveActivities init: $e');
    }

    if (Platform.isIOS) {
      _remoteCommandsChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'play':
            _remoteActions.add(RemotePlayerAction.play);
          case 'pause':
            _remoteActions.add(RemotePlayerAction.pause);
          case 'toggle':
            _remoteActions.add(RemotePlayerAction.toggle);
          case 'next':
            _remoteActions.add(RemotePlayerAction.next);
          case 'previous':
            _remoteActions.add(RemotePlayerAction.previous);
        }
      });
    }
  }

  void _onUrlScheme(UrlSchemeData data) {
    final host = (data.host ?? '').toLowerCase();
    final path = (data.path ?? '').toLowerCase().replaceAll('/', '');
    final action = host.isNotEmpty ? host : path;
    switch (action) {
      case 'play':
        _remoteActions.add(RemotePlayerAction.play);
      case 'pause':
        _remoteActions.add(RemotePlayerAction.pause);
      case 'toggle':
      case 'playpause':
        _remoteActions.add(RemotePlayerAction.toggle);
      case 'next':
        _remoteActions.add(RemotePlayerAction.next);
      case 'previous':
      case 'prev':
        _remoteActions.add(RemotePlayerAction.previous);
    }
  }

  Future<void> updateNowPlaying({
    required Track? track,
    required bool isPlaying,
    Duration position = Duration.zero,
    Duration? duration,
    bool forceLive = false,
  }) async {
    await ensureInitialized();

    try {
      if (track == null) {
        await HomeWidget.saveWidgetData<String>('title', 'Aria');
        await HomeWidget.saveWidgetData<String>('artist', 'Not playing');
        await HomeWidget.saveWidgetData<bool>('isPlaying', false);
        await HomeWidget.saveWidgetData<String>('artworkPath', '');
        await HomeWidget.saveWidgetData<String>('status', 'Idle');
      } else {
        await HomeWidget.saveWidgetData<String>('title', track.title);
        await HomeWidget.saveWidgetData<String>('artist', track.artist);
        await HomeWidget.saveWidgetData<bool>('isPlaying', isPlaying);
        final art = track.artworkPath ?? track.artworkUrl ?? '';
        await HomeWidget.saveWidgetData<String>('artworkPath', art);
        await HomeWidget.saveWidgetData<String>(
          'status',
          isPlaying ? 'Playing' : 'Paused',
        );
      }
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iosWidgetName,
      );
    } catch (e) {
      debugPrint('Home widget update: $e');
    }

    await _updateSystemNowPlaying(
      track: track,
      isPlaying: isPlaying,
      position: position,
      duration: duration,
    );

    await _syncLiveActivity(
      track: track,
      isPlaying: isPlaying,
      position: position,
      duration: duration,
      force: forceLive,
    );
  }

  Future<void> _updateSystemNowPlaying({
    required Track? track,
    required bool isPlaying,
    required Duration position,
    Duration? duration,
  }) async {
    if (!Platform.isIOS) return;
    try {
      if (track == null) {
        await _nowPlayingChannel.invokeMethod<void>('clear');
        return;
      }
      await _nowPlayingChannel.invokeMethod<void>('update', {
        'title': track.title,
        'artist': track.artist,
        'album': track.album,
        'isPlaying': isPlaying,
        'positionMs': position.inMilliseconds,
        'durationMs': duration?.inMilliseconds ?? track.durationMs,
        'artworkPath': track.artworkPath ?? '',
      });
    } catch (e) {
      debugPrint('System now playing: $e');
    }
  }

  Future<void> _syncLiveActivity({
    required Track? track,
    required bool isPlaying,
    required Duration position,
    Duration? duration,
    required bool force,
  }) async {
    try {
      final supported = await _liveActivities.areActivitiesSupported();
      if (!supported) {
        debugPrint('Live Activities not supported on this device');
        return;
      }
      final enabled = await _liveActivities.areActivitiesEnabled();
      if (!enabled) {
        debugPrint(
          'Live Activities disabled — enable in Settings → Aria → Live Activities',
        );
        return;
      }

      if (track == null) {
        if (_activityActive) {
          await _liveActivities.endActivity(liveActivityId);
          _activityActive = false;
          _lastTrackId = null;
          _lastPlaying = null;
        }
        return;
      }

      final now = DateTime.now();
      final trackChanged = _lastTrackId != track.id;
      final playChanged = _lastPlaying != isPlaying;
      final due = _lastLiveUpdate == null ||
          now.difference(_lastLiveUpdate!) >= const Duration(seconds: 4);

      if (!force && !trackChanged && !playChanged && !due && _activityActive) {
        return;
      }

      final data = <String, dynamic>{
        'title': track.title,
        'artist': track.artist,
        'isPlaying': isPlaying,
        'status': isPlaying ? 'Playing' : 'Paused',
        'positionMs': position.inMilliseconds,
        'durationMs': duration?.inMilliseconds ?? track.durationMs,
        'artworkUrl': track.artworkUrl ?? '',
        'artworkPath': track.artworkPath ?? '',
      };

      await _liveActivities.createOrUpdateActivity(
        liveActivityId,
        data,
        removeWhenAppIsKilled: false,
        iOSEnableRemoteUpdates: false,
      );
      _activityActive = true;
      _lastLiveUpdate = now;
      _lastTrackId = track.id;
      _lastPlaying = isPlaying;
    } catch (e, st) {
      debugPrint('Live activity sync failed: $e\n$st');
    }
  }

  Future<void> endLiveActivity() async {
    try {
      await _liveActivities.endActivity(liveActivityId);
    } catch (_) {}
    _activityActive = false;
  }

  Future<void> dispose() async {
    await _urlSub?.cancel();
    await _remoteActions.close();
  }
}
