import SwiftUI

@main
struct PuffwiseApp: App {

    /// App initializer that restores notification scheduling on launch.
    ///
    /// **Why Restore Notifications Here?**
    /// Local notifications are managed by the system notification center,
    /// which persists scheduled notifications across app restarts.
    /// However, if the user force-quits the app or the system clears notifications,
    /// we need to re-schedule them. By checking on every launch:
    /// - Notifications are restored if they were cleared
    /// - The schedule stays up-to-date with user preferences
    ///
    /// **About UserDefaults Access in init():**
    /// We access UserDefaults directly here instead of @AppStorage because
    /// @AppStorage is designed for use in SwiftUI views, not in App initializers.
    /// The keys match those used by @AppStorage in GoalSettingsView.
    init() {
        migrateToSharedDefaultsIfNeeded()
        syncReductionGoalIfNeeded()

        let reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")

        if reminderEnabled {
            // Read the stored hour and minute preferences
            // UserDefaults.standard.integer returns 0 if the key doesn't exist,
            // so we use 20:00 as the fallback default.
            let reminderHour = UserDefaults.standard.object(forKey: "reminderHour") as? Int ?? 20
            let reminderMinute = UserDefaults.standard.object(forKey: "reminderMinute") as? Int ?? 0

            // Schedule the notification asynchronously.
            // Task creates a new async context from synchronous code.
            Task {
                await NotificationManager.shared.scheduleDailyReminder(
                    hour: reminderHour,
                    minute: reminderMinute
                )
            }
        }
    }

    /// One-time migration of puff data from UserDefaults.standard to the shared App Group container.
    ///
    /// **Why migrate?**
    /// Before widget support, puffs were stored in UserDefaults.standard (the app's private
    /// container). The widget extension cannot read this container, so we copy the data to
    /// UserDefaults.shared (the App Group container) once. Subsequent reads/writes go directly
    /// to .shared, so this migration only runs once.
    ///
    /// **Migration flag:**
    /// We store a Bool in UserDefaults.standard to track whether migration has occurred.
    /// Keeping the flag in .standard (not .shared) ensures the migration runs exactly once
    /// per device, even if the shared container is cleared.
    /// Writes the current week's reduction target to the shared container so the widget
    /// reflects the active reduction plan rather than the static goal.
    ///
    /// Only runs when reduction mode is enabled. The widget reads `dailyPuffGoal` from
    /// the shared container; this keeps that value in sync with the plan's weekly target
    /// without requiring widget code changes.
    func syncReductionGoalIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "reductionModeEnabled"),
              let planData = UserDefaults.standard.data(forKey: "reductionPlanData"),
              let plan = try? JSONDecoder().decode(ReductionPlan.self, from: planData)
        else { return }

        UserDefaults.shared.set(plan.currentWeekTarget(), forKey: "dailyPuffGoal")
    }

    func migrateToSharedDefaultsIfNeeded() {
        let migrationKey = "didMigrateToSharedDefaults"
        guard !UserDefaults.standard.bool(forKey: migrationKey) else { return }

        if let data = UserDefaults.standard.data(forKey: "puffs") {
            UserDefaults.shared.set(data, forKey: "puffs")
        }
        if let goal = UserDefaults.standard.object(forKey: "dailyPuffGoal") as? Int {
            UserDefaults.shared.set(goal, forKey: "dailyPuffGoal")
        }

        UserDefaults.standard.set(true, forKey: migrationKey)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
