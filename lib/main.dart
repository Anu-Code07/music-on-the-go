import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/injection.dart';
import 'core/router/app_shell.dart';
import 'core/theme/studio_colors.dart';
import 'core/theme/studio_theme.dart';
import 'features/library/domain/usecases/ensure_seed_library.dart';
import 'features/player/data/datasources/widget_bridge_data_source.dart';
import 'features/player/presentation/bloc/player_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.remove();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: StudioColors.canvas,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const AriaApp());
}

class AriaApp extends StatefulWidget {
  const AriaApp({super.key});

  @override
  State<AriaApp> createState() => _AriaAppState();
}

class _AriaAppState extends State<AriaApp> {
  var _phase = _LaunchPhase.booting;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    try {
      try {
        final session = await AudioSession.instance;
        await session.configure(const AudioSessionConfiguration.music());
        await session.setActive(true);
      } catch (e) {
        debugPrint('AudioSession skipped: $e');
      }

      await configureDependencies();

      // ignore: unawaited_futures
      getIt<WidgetBridgeDataSource>().ensureInitialized().catchError((Object e) {
        debugPrint('Widget bridge init: $e');
      });

      // ignore: unawaited_futures
      getIt<EnsureSeedLibrary>()().catchError((Object e, StackTrace st) {
        debugPrint('Seed failed: $e\n$st');
      });

      if (!mounted) return;
      setState(() => _phase = _LaunchPhase.brand);

      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _phase = _LaunchPhase.ready);
    } catch (e, st) {
      debugPrint('Boot failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _phase = _LaunchPhase.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      title: 'Aria',
      debugShowCheckedModeBanner: false,
      theme: StudioTheme.light(),
      home: switch (_phase) {
        _LaunchPhase.booting || _LaunchPhase.brand => const _MiniMaxSplash(),
        _LaunchPhase.error => _BootError(message: _error ?? 'Unknown error'),
        _LaunchPhase.ready => const AppShell(),
      },
    );

    if (_phase != _LaunchPhase.ready) return app;

    return BlocProvider.value(
      value: getIt<PlayerBloc>(),
      child: app,
    );
  }
}

enum _LaunchPhase { booting, brand, ready, error }

class _MiniMaxSplash extends StatelessWidget {
  const _MiniMaxSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.canvas,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/app_icon.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.music_note_rounded,
                color: StudioColors.brandCoral,
                size: 72,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'ARIA',
              style: GoogleFonts.dmSans(
                color: StudioColors.ink,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                letterSpacing: 8,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 36,
              height: 2,
              color: StudioColors.brandCoral,
            ),
          ],
        ),
      ),
    );
  }
}

class _BootError extends StatelessWidget {
  const _BootError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudioColors.canvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Failed to start\n$message',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(color: StudioColors.steel),
          ),
        ),
      ),
    );
  }
}
