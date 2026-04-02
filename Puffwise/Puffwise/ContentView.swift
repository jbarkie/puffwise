import SwiftUI
import WidgetKit
import Charts

struct ContentView: View {
    // @State holds the array of puffs in memory during runtime.
    // Unlike @AppStorage, @State doesn't automatically persist to disk.
    // We'll manually save/load from UserDefaults using JSON encoding/decoding.
    @State private var puffs: [Puff] = []

    // @State holds the array of deleted puffs (trash) for 24-hour recovery.
    // These puffs can be restored by the user or will be auto-purged after expiry.
    @State private var deletedPuffs: [DeletedPuff] = []

    // Key used to store/retrieve puffs from UserDefaults
    private let puffsKey = "puffs"

    // Key used to store/retrieve deleted puffs from UserDefaults
    private let deletedPuffsKey = "deletedPuffs"

    // State variable to control the presentation of the goal settings sheet.
    // When true, the sheet appears; when false, it's dismissed.
    @State private var showingGoalSettings = false

    // @AppStorage provides automatic persistence for the daily puff goal.
    // This property is shared with GoalSettingsView using the same storage key "dailyPuffGoal".
    // Any changes in either view will automatically sync because they share the same UserDefaults key.
    // Default value of 10 is used on first launch when no value exists in UserDefaults.
    // store: .shared writes to the App Group container so the widget can read the same value.
    @AppStorage("dailyPuffGoal", store: .shared) private var dailyPuffGoal: Int = 10

    // @AppStorage for persisting the best streak achieved.
    // This value represents the longest consecutive days the user has met their daily goal.
    // It's only updated when the current streak exceeds the stored best.
    @AppStorage("bestStreak") private var bestStreak: Int = 0

    // Reduction mode state. When true, the effective daily goal is computed from the
    // active ReductionPlan instead of the static dailyPuffGoal.
    @AppStorage("reductionModeEnabled") private var reductionModeEnabled: Bool = false

    // JSON-encoded ReductionPlan, written by GoalSettingsView when the user enables
    // reduction mode. Stored in UserDefaults.standard (not shared) since the widget
    // reads the pre-computed weekly target from dailyPuffGoal in the shared container.
    @AppStorage("reductionPlanData") private var reductionPlanData: Data = Data()

    // Cached streak information to avoid redundant calculations.
    // Updated in updateStreakInfo() when puffs or dailyPuffGoal changes.
    @State private var streakInfo: StreakInfo = StreakInfo(
        currentStreak: 0,
        bestStreak: 0,
        todayGoalMet: false,
        todayCount: 0
    )

    // Computed property that filters puffs to only include today's entries.
    // This recalculates automatically whenever 'puffs' changes.
    private var todaysPuffs: [Puff] {
        // Calendar.current gives us the user's calendar (handles timezones, locales, etc.)
        let calendar = Calendar.current
        // Get the current date
        let now = Date()

        // Filter the puffs array to only include items from today
        return puffs.filter { puff in
            // isDate(_:inSameDayAs:) compares two dates to see if they're on the same day
            // This handles edge cases like midnight crossings correctly
            calendar.isDate(puff.timestamp, inSameDayAs: now)
        }
    }

    // Puffs logged since the start of the current calendar week (locale-aware).
    private var puffsThisWeek: [Puff] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return puffs.filter { weekInterval.contains($0.timestamp) }
    }

    // Decoded reduction plan, or nil when reduction mode is off or plan data is absent.
    private var currentReductionPlan: ReductionPlan? {
        guard reductionModeEnabled, !reductionPlanData.isEmpty else { return nil }
        return try? JSONDecoder().decode(ReductionPlan.self, from: reductionPlanData)
    }

    // The daily goal used for both display and streak calculation.
    // When reduction mode is active this is the dynamic effective daily goal;
    // otherwise it is the user's static dailyPuffGoal setting.
    private var activeGoal: Int {
        guard let plan = currentReductionPlan else { return dailyPuffGoal }
        return plan.effectiveDailyGoal(puffsThisWeek: puffsThisWeek.count)
    }

    // Trajectory data for the reduction curve chart. Empty when reduction mode is off.
    private var reductionTrajectory: [(week: Int, goal: Int)] {
        currentReductionPlan?.trajectoryPoints() ?? []
    }

    // Load puffs from UserDefaults
    // This function reads the stored JSON data and decodes it back into an array of Puff objects.
    // Reads from UserDefaults.shared (App Group container) so the widget extension can access
    // the same data.
    private func loadPuffs() {
        // Get the Data object stored under our key
        guard let data = UserDefaults.shared.data(forKey: puffsKey) else {
            // If there's no data (first app launch), keep the empty array
            return
        }

        // Try to decode the JSON data into an array of Puff objects
        do {
            let decoded = try JSONDecoder().decode([Puff].self, from: data)
            puffs = decoded
        } catch {
            // If decoding fails (corrupted data, format change, etc.), log the error
            // and keep the empty array
            print("Failed to load puffs: \(error)")
        }
    }

    // Save puffs to UserDefaults
    // This function encodes the puffs array to JSON and stores it to disk.
    // Writes to UserDefaults.shared (App Group container) so the widget extension can read
    // the latest data. After saving, signals WidgetKit to reload all widget timelines so
    // the home screen widget reflects the new count immediately.
    private func savePuffs() {
        do {
            // Encode the puffs array to JSON Data
            let data = try JSONEncoder().encode(puffs)
            // Save the data to the shared App Group container
            UserDefaults.shared.set(data, forKey: puffsKey)
            // Tell WidgetKit to reload all timelines so widgets update now
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            // If encoding fails (should be rare), log the error
            print("Failed to save puffs: \(error)")
        }
    }

    // Load deleted puffs from UserDefaults
    // Loads the trash and automatically purges expired items (older than 24 hours).
    private func loadDeletedPuffs() {
        guard let data = UserDefaults.standard.data(forKey: deletedPuffsKey) else {
            // No deleted puffs stored yet
            return
        }

        do {
            let decoded = try JSONDecoder().decode([DeletedPuff].self, from: data)
            // Auto-purge expired items on load
            // The onChange modifier will automatically save the purged array
            deletedPuffs = decoded.purgingExpired()
        } catch {
            print("Failed to load deleted puffs: \(error)")
        }
    }

    // Save deleted puffs to UserDefaults
    // Purges expired items before saving to keep storage clean.
    private func saveDeletedPuffs() {
        do {
            // Purge expired items before saving
            deletedPuffs = deletedPuffs.purgingExpired()
            let data = try JSONEncoder().encode(deletedPuffs)
            UserDefaults.standard.set(data, forKey: deletedPuffsKey)
        } catch {
            print("Failed to save deleted puffs: \(error)")
        }
    }

    // Update cached streak information and best streak if needed.
    // This method calculates the streak once and updates both the cached streakInfo
    // and the persisted bestStreak if the current streak exceeds it.
    // Called when puffs change, goal changes, or on app launch.
    private func updateStreakInfo() {
        // Calculate streak once
        let info = puffs.calculateStreak(dailyGoal: activeGoal, storedBestStreak: bestStreak)

        // Update cached state
        streakInfo = info

        // Update best streak if current exceeds it
        if info.currentStreak > bestStreak {
            bestStreak = info.currentStreak
        }
    }

    var body: some View {
        // NavigationStack is the modern SwiftUI container for navigation (iOS 16+).
        // It replaces the older NavigationView and provides better control over navigation flow.
        // Everything inside NavigationStack can use navigation features like NavigationLink.
        NavigationStack {
            VStack(spacing: 30) {
                // App header with icon and title
                VStack(spacing: 10) {
                    Image(systemName: "wind")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Puffwise")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Spacer()

                // Puff counter display
                VStack(spacing: 8) {
                    Text("Today's Puffs")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    // Display today's count using the filtered array.
                    // Because todaysPuffs is a computed property, this updates automatically
                    // whenever a new puff is added or when the day changes.
                    Text("\(todaysPuffs.count)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(.primary)

                    // Goal progress display
                    // When reduction mode is off, shows the static daily goal.
                    // When on, shows the effective daily goal (remaining weekly budget ÷ days left).
                    Text("\(todaysPuffs.count) of \(activeGoal) puffs")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Reduction mode status — week number and weekly target
                    if let plan = currentReductionPlan {
                        let weekNum = plan.weeksElapsed() + 1
                        Text("Reduction Plan Week \(weekNum) — \(plan.currentWeekTarget()) puffs/day target")
                            .font(.caption)
                            .foregroundStyle(.blue.opacity(0.8))
                    }

                    // Statistics display
                    // Shows 7-day and 30-day averages to help users track trends
                    let stats = puffs.calculateStatistics()
                    if stats.hasData {
                        VStack(spacing: 2) {
                            Text(String(format: "7-day avg: %.1f/day", stats.sevenDayAverage))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: "30-day avg: %.1f/day", stats.thirtyDayAverage))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 8)
                    }

                    // Streak display
                    // Only shown when there's an active streak or historical best streak
                    // Motivates users by showing their consecutive days meeting goals
                    if streakInfo.hasActiveStreak || streakInfo.bestStreak > 0 {
                        VStack(spacing: 4) {
                            // Current streak with flame icon (universal streak symbol)
                            if streakInfo.hasActiveStreak {
                                HStack(spacing: 6) {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(.orange)
                                        .font(.subheadline)
                                    Text("\(streakInfo.currentStreak) day\(streakInfo.currentStreak == 1 ? "" : "s") streak")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                }
                            }

                            // Best streak (only if different from current and greater than 0)
                            if streakInfo.bestStreak > 0 &&
                               streakInfo.bestStreak > streakInfo.currentStreak {
                                Text("Best: \(streakInfo.bestStreak) day\(streakInfo.bestStreak == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

                // Reduction curve chart — visible only when reduction mode is active.
                // Shows the compounding weekly goal trajectory from the current week to the
                // minimum floor. A dashed rule marks where the user is today.
                if !reductionTrajectory.isEmpty, let plan = currentReductionPlan {
                    ReductionCurveView(
                        trajectory: reductionTrajectory,
                        currentWeekOffset: plan.weeksElapsed()
                    )
                    .padding(.top, 8)
                }

                // Main action button
                Button(action: {
                    // Create a new Puff with the current timestamp and append it to the array.
                    // The Puff initializer defaults to Date() (current time) and a new UUID.
                    puffs.append(Puff())
                    // Note: No need to manually call savePuffs() here anymore!
                    // The .onChange(of: puffs) modifier automatically saves when the array changes.
                    // SwiftUI detects the @State change and re-renders the UI automatically.
                }) {
                    // Button content - label and icon
                    Label("Log Puff", systemImage: "plus.circle.fill")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 40)
                        .background(.blue)
                        .cornerRadius(16)
                }

                Spacer()
            }
            .padding()
            // .navigationTitle sets the title in the navigation bar
            // This is a required part of the NavigationStack pattern
            .navigationTitle("Today")
            // .navigationBarTitleDisplayMode(.inline) makes the title appear on the same
            // horizontal line as toolbar items, instead of the large centered display
            .navigationBarTitleDisplayMode(.inline)
            // .toolbar lets us add items to the navigation bar
            // Common placements: .topBarTrailing (top-right), .topBarLeading (top-left), .bottomBar
            .toolbar {
                // Settings button on the left side of the toolbar
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // Set the state variable to true, which triggers the sheet presentation
                        // The sheet modifier below watches this variable and shows/hides accordingly
                        showingGoalSettings = true
                    } label: {
                        // SF Symbol "gear" is the standard icon for settings across iOS
                        // Label provides both the icon and accessibility text
                        Label("Settings", systemImage: "gear")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    // NavigationLink creates a button that navigates to another view
                    // The destination parameter specifies which view to show
                    // This is declarative navigation - we describe where to go, not how
                    // The $ prefix creates a binding from @State, allowing HistoryView to access the data
                    // Now passing deletedPuffs binding to enable undo functionality
                    NavigationLink(destination: HistoryView(puffs: $puffs, deletedPuffs: $deletedPuffs)) {
                        // SF Symbols provide thousands of icons
                        // "chart.bar" is perfect for representing historical data
                        Label("History", systemImage: "chart.bar")
                    }
                }
            }
            // .onAppear is called when the view first appears on screen
            // We use it to load our saved puffs and deleted puffs from UserDefaults
            .onAppear {
                loadPuffs()
                loadDeletedPuffs()
                updateStreakInfo()
            }
            // .onChange monitors the puffs array for any modifications.
            // When the array changes (add, edit, delete), automatically save to UserDefaults.
            // This ensures all changes persist without requiring manual savePuffs() calls.
            // The closure receives the old and new values, but we only need to trigger save.
            // Also updates best streak if current exceeds it.
            .onChange(of: puffs) { _, _ in
                savePuffs()
                updateStreakInfo()
            }
            // .onChange monitors the daily goal for changes.
            // When the goal changes, recalculate streak and update best if needed.
            // This ensures streak calculations are accurate when users adjust their goals.
            .onChange(of: dailyPuffGoal) { _, _ in
                updateStreakInfo()
            }
            // When reduction mode is toggled or the plan changes, recalculate the streak
            // so it immediately reflects the new effective daily goal.
            .onChange(of: reductionModeEnabled) { _, _ in updateStreakInfo() }
            .onChange(of: reductionPlanData) { _, _ in updateStreakInfo() }
            // .onChange monitors the deleted puffs array for changes.
            // When items are added, removed, or restored, automatically save to UserDefaults.
            .onChange(of: deletedPuffs) { _, _ in
                saveDeletedPuffs()
            }
            // .sheet presents a modal view when the binding variable becomes true.
            // This is the standard SwiftUI pattern for presenting settings, forms, or detail views.
            // When showingGoalSettings changes to true, the sheet slides up from the bottom.
            // When dismissed (via the Done button in GoalSettingsView), it automatically sets back to false.
            .sheet(isPresented: $showingGoalSettings) {
                // Pass the puffs binding to enable CSV export functionality
                GoalSettingsView(puffs: $puffs)
            }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Reduction Curve Chart

/// A compact line chart showing the compounding weekly goal reduction trajectory.
///
/// Displayed on the home screen when reduction mode is active. The X axis shows
/// week numbers relative to the plan's start; the Y axis shows the daily puff goal
/// for that week. A dashed rule marks the current week so users can see progress.
struct ReductionCurveView: View {
    let trajectory: [(week: Int, goal: Int)]
    let currentWeekOffset: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Reduction Plan")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Daily goal (puffs) by week")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Chart {
                // Goal trajectory line
                ForEach(trajectory, id: \.week) { point in
                    LineMark(
                        x: .value("Week", point.week),
                        y: .value("Goal", point.goal)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                    // Filled area under the line for visual weight
                    AreaMark(
                        x: .value("Week", point.week),
                        y: .value("Goal", point.goal)
                    )
                    .foregroundStyle(.blue.opacity(0.08))
                    .interpolationMethod(.catmullRom)
                }

                // Dashed rule marking the current week
                RuleMark(x: .value("Now", currentWeekOffset))
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                    .annotation(position: .overlay, alignment: .topLeading) {
                        Text("Now")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
            }
            .frame(height: 120)
            .chartXScale(domain: 0...(trajectory.last?.week ?? 0))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let week = value.as(Int.self) {
                            Text("W\(week)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let goal = value.as(Int.self) {
                            Text("\(goal)")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}
