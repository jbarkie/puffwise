//
//  NotificationManager.swift
//  Puffwise
//
//  Manages local notification scheduling for daily reminders.
//  This singleton class handles notification permissions and scheduling.
//

import Foundation
import UserNotifications

/// Singleton class responsible for managing daily reminder notifications.
///
/// **About the Singleton Pattern:**
/// A singleton ensures only one instance of this class exists throughout the app lifecycle.
/// This is appropriate for notification management because:
/// - We need consistent state across the app (one notification manager)
/// - The notification center itself is a shared system resource
/// - Multiple instances could cause duplicate notifications
///
/// **About UNUserNotificationCenter:**
/// UNUserNotificationCenter is the central object for managing notification-related activities.
/// It handles:
/// - Requesting authorization from the user
/// - Scheduling local notifications
/// - Managing pending notification requests
/// - Handling delivered notifications
final class NotificationManager {

    /// Shared singleton instance.
    /// Access via `NotificationManager.shared` throughout the app.
    static let shared = NotificationManager()

    /// Identifier for the daily reminder notification.
    /// Using a constant identifier allows us to:
    /// - Cancel specific notifications by ID
    /// - Replace existing notifications (avoid duplicates)
    /// - Query pending notifications by ID
    static let dailyReminderIdentifier = "dailyPuffReminder"

    /// Reference to the system notification center.
    /// UNUserNotificationCenter.current() returns the shared notification center for the app.
    private let notificationCenter = UNUserNotificationCenter.current()

    /// Private initializer prevents external instantiation.
    /// This enforces the singleton pattern - only `shared` can create an instance.
    private init() {}

    // MARK: - Permission Handling

    /// Requests notification authorization from the user.
    ///
    /// **About Notification Permissions:**
    /// iOS requires explicit user permission to display notifications.
    /// The first time this is called, iOS shows a system alert asking the user to allow/deny.
    /// Subsequent calls return the existing authorization status without showing the alert.
    ///
    /// **Options Explained:**
    /// - `.alert`: Permission to display banner/alert notifications
    /// - `.sound`: Permission to play notification sounds
    /// - `.badge`: Permission to show badge numbers on the app icon
    ///
    /// - Returns: `true` if authorization was granted, `false` otherwise
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            return granted
        } catch {
            print("Error requesting notification permission: \(error.localizedDescription)")
            return false
        }
    }

    /// Checks the current notification authorization status.
    ///
    /// **Authorization Status Values:**
    /// - `.notDetermined`: User hasn't been asked yet
    /// - `.denied`: User explicitly denied permission
    /// - `.authorized`: User granted permission
    /// - `.provisional`: Provisional authorization (quiet notifications)
    /// - `.ephemeral`: App Clip authorization (temporary)
    ///
    /// - Returns: Current `UNAuthorizationStatus`
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Notification Scheduling

    /// Schedules a daily repeating notification at the specified time.
    ///
    /// **About UNCalendarNotificationTrigger:**
    /// This trigger type fires at specific calendar dates/times.
    /// By using only hour and minute components with `repeats: true`,
    /// iOS will fire the notification daily at that time.
    ///
    /// **Notification Content:**
    /// - `title`: The main notification text (shown in bold)
    /// - `body`: Additional detail text (shown below title)
    /// - `sound`: The notification sound (`.default` is a brief ding)
    ///
    /// - Parameters:
    ///   - hour: The hour (0-23) to show the notification
    ///   - minute: The minute (0-59) to show the notification
    func scheduleDailyReminder(hour: Int, minute: Int) async {
        // Cancel any existing reminder first to avoid duplicates
        cancelDailyReminder()

        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "How are you doing with your puff goal today?"
        content.sound = .default

        // Create date components for the trigger
        // By specifying only hour and minute, iOS fires this daily at that time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        // Create a calendar-based trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // Create the notification request with our identifier
        let request = UNNotificationRequest(
            identifier: Self.dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        // Schedule the notification
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Error scheduling notification: \(error.localizedDescription)")
        }
    }

    /// Cancels any pending daily reminder notifications.
    ///
    /// **About removePendingNotificationRequests:**
    /// This removes notifications that are scheduled but haven't fired yet.
    /// By passing our identifier, we only remove our daily reminder,
    /// leaving any other notifications (if any) intact.
    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [Self.dailyReminderIdentifier]
        )
    }

    // MARK: - Testing Helpers

    /// Creates notification content for testing purposes.
    /// This allows tests to verify content without scheduling actual notifications.
    ///
    /// - Returns: Configured `UNMutableNotificationContent` with reminder text
    func createReminderContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "How are you doing with your puff goal today?"
        content.sound = .default
        return content
    }

    /// Creates a calendar trigger for testing purposes.
    /// This allows tests to verify trigger configuration without scheduling.
    ///
    /// - Parameters:
    ///   - hour: The hour (0-23) for the trigger
    ///   - minute: The minute (0-59) for the trigger
    /// - Returns: Configured `UNCalendarNotificationTrigger`
    func createDailyTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    }

    /// Returns the count of pending notification requests with the daily reminder identifier.
    /// This is useful for testing to verify scheduling and cancellation behavior.
    ///
    /// - Returns: Number of pending daily reminder notifications
    func pendingDailyReminderCount() async -> Int {
        let pendingRequests = await notificationCenter.pendingNotificationRequests()
        return pendingRequests.filter { $0.identifier == Self.dailyReminderIdentifier }.count
    }
}
