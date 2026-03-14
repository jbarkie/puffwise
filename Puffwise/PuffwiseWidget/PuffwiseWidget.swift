//
//  PuffwiseWidget.swift
//  PuffwiseWidget
//

import WidgetKit
import SwiftUI

// MARK: - Data Loader

/// Reads today's puff count and daily goal from the shared App Group container.
///
/// **Why a free function?**
/// The widget extension is a separate process that cannot access the main app's
/// in-memory state (no ContentView, no @State, no @ObservableObject). This function
/// is the widget's only data path, reading from the same UserDefaults.shared container
/// that the main app writes to via savePuffs() and @AppStorage(store: .shared).
///
/// **App Group requirement:**
/// Both the Puffwise and PuffwiseWidgetExtension targets must have the App Group
/// capability set to "group.com.puffwise.app" in Xcode's Signing & Capabilities.
/// Without this, UserDefaults(suiteName:) returns a private container that the
/// other process cannot read.
private func loadWidgetData() -> (count: Int, goal: Int) {
    let defaults = UserDefaults(suiteName: "group.com.puffwise.app")!
    let rawGoal = defaults.integer(forKey: "dailyPuffGoal")
    // integer(forKey:) returns 0 when the key is missing; fall back to 10 puffs
    let goal = rawGoal > 0 ? max(1, min(100, rawGoal)) : 10

    guard let data = defaults.data(forKey: "puffs"),
          let puffs = try? JSONDecoder().decode([Puff].self, from: data)
    else { return (0, goal) }

    let todayCount = puffs.filter { Calendar.current.isDateInToday($0.timestamp) }.count
    return (todayCount, goal)
}

// MARK: - Timeline Entry

/// A snapshot of data at a specific point in time, rendered by WidgetKit.
///
/// **Why TimelineEntry?**
/// WidgetKit renders widgets offline (without running the app) by pre-computing a
/// "timeline" of entries. Each entry describes the widget's state at a future time.
/// The system selects the entry matching the current time to display.
struct PuffwiseEntry: TimelineEntry {
    let date: Date
    let puffCount: Int
    let goal: Int

    /// Progress toward the daily goal, clamped to [0, 1] for the ring display.
    /// A full ring (1.0) appears when the user has reached or exceeded their goal.
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(puffCount) / Double(goal), 1.0)
    }

    /// True when the user is at or under their daily puff target (on track to reduce).
    var isGoalMet: Bool {
        puffCount <= goal
    }
}

// MARK: - Timeline Provider

/// Supplies WidgetKit with timeline entries to keep the widget up to date.
///
/// **StaticConfiguration:**
/// No per-widget user settings needed, so we use StaticConfiguration (vs IntentConfiguration).
///
/// **Refresh policy:**
/// We schedule the next refresh at the start of the next hour. This handles the midnight
/// day rollover (today's count resets) and keeps the count roughly current.
/// The main app also calls WidgetCenter.shared.reloadAllTimelines() after every puff save,
/// so the widget updates immediately when the user opens the app and logs a puff.
struct PuffwiseProvider: TimelineProvider {
    func placeholder(in context: Context) -> PuffwiseEntry {
        // Placeholder shown while the real data loads; use representative sample values.
        PuffwiseEntry(date: Date(), puffCount: 5, goal: 10)
    }

    func getSnapshot(in context: Context, completion: @escaping (PuffwiseEntry) -> Void) {
        // Snapshot is used in the widget gallery preview — load live data for accuracy.
        let (count, goal) = loadWidgetData()
        completion(PuffwiseEntry(date: Date(), puffCount: count, goal: goal))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PuffwiseEntry>) -> Void) {
        let (count, goal) = loadWidgetData()
        let entry = PuffwiseEntry(date: Date(), puffCount: count, goal: goal)

        // Refresh at the top of the next hour.
        let nextHour = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(minute: 0),
            matchingPolicy: .nextTime
        ) ?? Date().addingTimeInterval(3600)

        let timeline = Timeline(entries: [entry], policy: .after(nextHour))
        completion(timeline)
    }
}

// MARK: - Widget View

/// The visual representation rendered on the home screen (small widget).
///
/// **Layout:**
/// App name + icon → circular progress ring (count/goal inside) → status label.
///
/// **Circular progress ring:**
/// - Background: a full Circle stroked at low opacity as the "track".
/// - Foreground: a second Circle whose visible arc is controlled by `.trim(from:to:)`.
///   The `to` value comes from `entry.progress` (0…1), so a full ring = goal reached.
/// - `rotationEffect(.degrees(-90))` starts the arc at 12 o'clock rather than 3 o'clock.
struct PuffwiseWidgetView: View {
    var entry: PuffwiseEntry

    var body: some View {
        VStack(spacing: 6) {
            // App header
            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.caption2)
                Text("Puffwise")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.secondary)

            // Circular progress ring
            ZStack {
                // Background track
                Circle()
                    .stroke(.secondary.opacity(0.2), lineWidth: 8)

                // Progress arc — green when on track, orange when over goal
                Circle()
                    .trim(from: 0, to: entry.progress)
                    .stroke(
                        entry.isGoalMet ? Color.green : Color.orange,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                // Count label inside the ring
                VStack(spacing: 1) {
                    Text("\(entry.puffCount)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("of \(entry.goal)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 75, height: 75)

            // Status label
            Text(entry.isGoalMet ? "On track" : "Over goal")
                .font(.caption2)
                .foregroundStyle(entry.isGoalMet ? .green : .orange)
        }
        .padding(10)
    }
}

// MARK: - Widget Configuration

/// The home screen widget definition, registered with WidgetKit.
///
/// **No @main here:**
/// The extension's entry point is PuffwiseWidgetBundle (in PuffwiseWidgetBundle.swift),
/// which groups this widget alongside any future widgets (Control, Live Activity, etc.).
///
/// **kind string:**
/// A stable identifier used by WidgetKit to differentiate widgets within the same
/// extension. If you ever rename the struct, keep the kind string the same to avoid
/// resetting existing placed widgets.
struct PuffwiseWidget: Widget {
    let kind: String = "PuffwiseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PuffwiseProvider()) { entry in
            PuffwiseWidgetView(entry: entry)
                // containerBackground replaces the deprecated .background modifier for widgets.
                // .fill.tertiary gives a neutral system background that adapts to light/dark mode.
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Puffwise")
        .description("Today's puff count and goal.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Xcode Preview

#Preview(as: .systemSmall) {
    PuffwiseWidget()
} timeline: {
    PuffwiseEntry(date: .now, puffCount: 5, goal: 10)
    PuffwiseEntry(date: .now, puffCount: 12, goal: 10)
}
