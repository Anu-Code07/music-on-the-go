import Flutter
import MediaPlayer
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var nowPlayingChannel: FlutterMethodChannel?
  private var commandChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    setupRemoteCommands()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()
    nowPlayingChannel = FlutterMethodChannel(
      name: "com.anurag.studio/now_playing",
      binaryMessenger: messenger
    )
    commandChannel = FlutterMethodChannel(
      name: "com.anurag.studio/remote_commands",
      binaryMessenger: messenger
    )

    nowPlayingChannel?.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }
      switch call.method {
      case "update":
        self.updateNowPlaying(call.arguments as? [String: Any])
        result(nil)
      case "clear":
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setupRemoteCommands() {
    let center = MPRemoteCommandCenter.shared()
    center.playCommand.isEnabled = true
    center.pauseCommand.isEnabled = true
    center.togglePlayPauseCommand.isEnabled = true
    center.nextTrackCommand.isEnabled = true
    center.previousTrackCommand.isEnabled = true

    center.playCommand.addTarget { [weak self] _ in
      self?.commandChannel?.invokeMethod("play", arguments: nil)
      return .success
    }
    center.pauseCommand.addTarget { [weak self] _ in
      self?.commandChannel?.invokeMethod("pause", arguments: nil)
      return .success
    }
    center.togglePlayPauseCommand.addTarget { [weak self] _ in
      self?.commandChannel?.invokeMethod("toggle", arguments: nil)
      return .success
    }
    center.nextTrackCommand.addTarget { [weak self] _ in
      self?.commandChannel?.invokeMethod("next", arguments: nil)
      return .success
    }
    center.previousTrackCommand.addTarget { [weak self] _ in
      self?.commandChannel?.invokeMethod("previous", arguments: nil)
      return .success
    }
  }

  private func updateNowPlaying(_ args: [String: Any]?) {
    guard let args else { return }
    var info = [String: Any]()
    if let title = args["title"] as? String { info[MPMediaItemPropertyTitle] = title }
    if let artist = args["artist"] as? String { info[MPMediaItemPropertyArtist] = artist }
    if let album = args["album"] as? String { info[MPMediaItemPropertyAlbumTitle] = album }

    let durationMs = (args["durationMs"] as? NSNumber)?.doubleValue ?? 0
    let positionMs = (args["positionMs"] as? NSNumber)?.doubleValue ?? 0
    if durationMs > 0 {
      info[MPMediaItemPropertyPlaybackDuration] = durationMs / 1000.0
    }
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = positionMs / 1000.0
    info[MPNowPlayingInfoPropertyPlaybackRate] = ((args["isPlaying"] as? Bool) == true) ? 1.0 : 0.0

    if let path = args["artworkPath"] as? String,
      !path.isEmpty,
      let image = UIImage(contentsOfFile: path)
    {
      info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
    }

    MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    UIApplication.shared.beginReceivingRemoteControlEvents()
  }
}
