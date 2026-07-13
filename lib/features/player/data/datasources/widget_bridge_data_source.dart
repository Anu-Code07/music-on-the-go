import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:live_activities/live_activities.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../library/domain/entities/track.dart';

class WidgetBridgeDataSource {
  WidgetBridgeDataSource();

  static const appGroupId = 'group.com.anurag.studio';
  static const androidWidgetName = 'StudioPlayerWidget';
  static const iosWidgetName = 'StudioPlayerWidget';
  static const liveActivityId = 'aria_now_playing';

  final LiveActivities _liveActivities = LiveActivities();

  bool _initialized = false;
  bool _activityActive = false;
  DateTime? _lastLiveUpdate;
  String? _lastTrackId;
  bool? _lastPlaying;

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
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      debugPrint('LiveActivities init: $e');
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

    await _syncLiveActivity(
      track: track,
      isPlaying: isPlaying,
      position: position,
      duration: duration,
      force: forceLive,
    );
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
      if (!supported) return;
      final enabled = await _liveActivities.areActivitiesEnabled();
      if (!enabled) return;

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
      );
      _activityActive = true;
      _lastLiveUpdate = now;
      _lastTrackId = track.id;
      _lastPlaying = isPlaying;
    } catch (e) {
      debugPrint('Live activity sync: $e');
    }
  }

  Future<void> endLiveActivity() async {
    try {
      await _liveActivities.endActivity(liveActivityId);
    } catch (_) {}
    _activityActive = false;
  }
}
