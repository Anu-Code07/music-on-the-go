import ActivityKit
import SwiftUI
import WidgetKit

private let appGroupId = "group.com.anurag.studio"

@main
struct AriaWidgetsBundle: WidgetBundle {
  var body: some Widget {
    StudioPlayerWidget()
    if #available(iOS 16.1, *) {
      AriaLiveActivityWidget()
    }
  }
}

// MARK: - Home screen widget (home_widget package)

struct StudioPlayerEntry: TimelineEntry {
  let date: Date
  let title: String
  let artist: String
  let status: String
  let isPlaying: Bool
}

struct StudioPlayerProvider: TimelineProvider {
  func placeholder(in context: Context) -> StudioPlayerEntry {
    StudioPlayerEntry(
      date: Date(),
      title: "Aria",
      artist: "Not playing",
      status: "Idle",
      isPlaying: false
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (StudioPlayerEntry) -> Void) {
    completion(currentEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<StudioPlayerEntry>) -> Void) {
    let entry = currentEntry()
    completion(Timeline(entries: [entry], policy: .atEnd))
  }

  private func currentEntry() -> StudioPlayerEntry {
    let defaults = UserDefaults(suiteName: appGroupId)
    return StudioPlayerEntry(
      date: Date(),
      title: defaults?.string(forKey: "title") ?? "Aria",
      artist: defaults?.string(forKey: "artist") ?? "Not playing",
      status: defaults?.string(forKey: "status") ?? "Idle",
      isPlaying: defaults?.bool(forKey: "isPlaying") ?? false
    )
  }
}

struct StudioPlayerWidget: Widget {
  let kind = "StudioPlayerWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: StudioPlayerProvider()) { entry in
      StudioPlayerWidgetView(entry: entry)
    }
    .configurationDisplayName("Aria Now Playing")
    .description("See what's playing in Aria.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct StudioPlayerWidgetView: View {
  let entry: StudioPlayerEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("ARIA")
        .font(.system(size: 10, weight: .semibold))
        .tracking(2)
        .foregroundStyle(Color(red: 0.56, green: 0.56, blue: 0.58))
      Text(entry.title)
        .font(.system(size: 16, weight: .semibold))
        .foregroundStyle(Color(red: 0.04, green: 0.04, blue: 0.04))
        .lineLimit(1)
      Text(entry.artist)
        .font(.system(size: 13, weight: .regular))
        .foregroundStyle(Color(red: 0.37, green: 0.37, blue: 0.37))
        .lineLimit(1)
      Spacer(minLength: 0)
      Text(entry.status.uppercased())
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(
          entry.isPlaying
            ? Color(red: 1.0, green: 0.33, blue: 0.19)
            : Color(red: 0.37, green: 0.37, blue: 0.37)
        )
    }
    .padding(16)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    .background(Color.white)
  }
}

// MARK: - Live Activity (live_activities package contract)

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {}

  var id = UUID()
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    "\(id)_\(key)"
  }
}

let sharedDefault = UserDefaults(suiteName: appGroupId)!

@available(iOSApplicationExtension 16.1, *)
struct AriaLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      lockScreenView(for: context)
    } dynamicIsland: { context in
      let title = sharedDefault.string(forKey: context.attributes.prefixedKey("title")) ?? "Aria"
      let artist = sharedDefault.string(forKey: context.attributes.prefixedKey("artist")) ?? ""
      let isPlaying = sharedDefault.bool(forKey: context.attributes.prefixedKey("isPlaying"))
      let status = sharedDefault.string(forKey: context.attributes.prefixedKey("status"))
        ?? (isPlaying ? "Playing" : "Paused")

      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Image(systemName: isPlaying ? "waveform" : "pause.fill")
            .font(.title2)
            .foregroundStyle(.white)
            .padding(.leading, 8)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text(status)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color(red: 1.0, green: 0.33, blue: 0.19))
            .padding(.trailing, 8)
        }
        DynamicIslandExpandedRegion(.center) {
          VStack(spacing: 2) {
            Text(title)
              .font(.headline)
              .lineLimit(1)
            Text(artist)
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("Open Aria")
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
        }
      } compactLeading: {
        Image(systemName: isPlaying ? "play.fill" : "pause.fill")
          .foregroundStyle(.white)
      } compactTrailing: {
        Text(title)
          .font(.caption2.weight(.semibold))
          .lineLimit(1)
          .frame(maxWidth: 72)
      } minimal: {
        Image(systemName: isPlaying ? "play.fill" : "pause.fill")
      }
    }
  }

  @ViewBuilder
  private func lockScreenView(
    for context: ActivityViewContext<LiveActivitiesAppAttributes>
  ) -> some View {
    let title = sharedDefault.string(forKey: context.attributes.prefixedKey("title")) ?? "Aria"
    let artist = sharedDefault.string(forKey: context.attributes.prefixedKey("artist")) ?? ""
    let isPlaying = sharedDefault.bool(forKey: context.attributes.prefixedKey("isPlaying"))
    let status = sharedDefault.string(forKey: context.attributes.prefixedKey("status"))
      ?? (isPlaying ? "Playing" : "Paused")
    let artworkPath = sharedDefault.string(forKey: context.attributes.prefixedKey("artworkPath"))

    HStack(spacing: 14) {
      ZStack {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(Color.white.opacity(0.12))
          .frame(width: 56, height: 56)
        if let artworkPath,
          !artworkPath.isEmpty,
          let image = UIImage(contentsOfFile: artworkPath)
        {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
          Image(systemName: "music.note")
            .foregroundStyle(.white.opacity(0.8))
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(.white)
          .lineLimit(1)
        Text(artist)
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(.white.opacity(0.72))
          .lineLimit(1)
        Text(status.uppercased())
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(Color(red: 1.0, green: 0.33, blue: 0.19))
      }
      Spacer(minLength: 0)
      Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
        .font(.system(size: 34))
        .foregroundStyle(.white)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 14)
    .activityBackgroundTint(Color.black.opacity(0.85))
    .activitySystemActionForegroundColor(.white)
  }
}
