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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
