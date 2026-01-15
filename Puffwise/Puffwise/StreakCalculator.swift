//
//  StreakCalculator.swift
//  Puffwise
//
//  Streak calculation utilities for tracking consecutive days meeting daily goals.
//  This file provides the logic to calculate current and best streaks,
//  motivating users to maintain their progress toward reducing puff counts.
//

import Foundation

// MARK: - StreakInfo

/// Represents streak information and goal progress for the user.
///
/// A StreakInfo bundles together:
/// - The current active streak (consecutive days meeting the goal)
/// - The all-time best streak (historical achievement)
/// - Today's goal status (whether the goal has been met today)
/// - Today's puff count
///
/// This struct conforms to Equatable so it can be compared in tests and UI updates.
struct StreakInfo: Equatable {
    /// The current number of consecutive days meeting or beating the daily goal.
    /// This count excludes today if today's goal has not been met yet.
    let currentStreak: Int

    /// The longest streak ever achieved.
    /// This value is persisted in UserDefaults and represents a personal best.
    let bestStreak: Int

    /// Whether today's puff count is at or below the daily goal.
    /// True means the goal is met; false means still working on it or exceeded.
    let todayGoalMet: Bool

    /// The number of puffs logged today.
    let todayCount: Int

    /// Convenience property that indicates if the user has an active streak.
    /// Returns true if currentStreak is greater than 0.
    var hasActiveStreak: Bool {
        currentStreak > 0
    }
}

// MARK: - Array Extension for Streak Calculation

/// Extension on Array where elements are Puff objects.
///
/// This extension adds streak calculation functionality directly to arrays of Puff objects,
/// making the API very natural: puffs.calculateStreak(dailyGoal:storedBestStreak:)
///
/// Extensions are a powerful Swift feature that lets us add methods to existing types
/// without modifying their original implementation. The `where Element == Puff` constraint
/// means these methods are only available on arrays containing Puff objects.
///
/// **Why extend Array<Puff>?**
/// Following the same pattern as PuffGrouping.swift, this keeps our API consistent and
/// fluent. It's more readable to write `puffs.calculateStreak(...)` than to have a
/// separate StreakCalculator class with static methods.
extension Array where Element == Puff {

    /// Calculates the current streak, best streak, and today's status.
    ///
    /// This is the main streak calculation method that:
    /// 1. Validates that a goal is set
    /// 2. Groups puffs by day
    /// 3. Checks today's goal status
    /// 4. Walks backward through days to count consecutive days meeting the goal
    /// 5. Updates the best streak if the current streak exceeds it
    ///
    /// **Algorithm:**
    /// Starting from today (or yesterday if today's goal isn't met), we walk backward
    /// through the calendar one day at a time. For each day, we check if the puff count
    /// was at or below the daily goal. If yes, we increment the streak. If no (or if
    /// there's no data for that day), we stop counting.
    ///
    /// **Why exclude incomplete today?**
    /// If today's goal hasn't been met yet, we don't count it in the current streak.
    /// This prevents false streak inflation and keeps the streak count accurate. Users
    /// can still see today's progress separately via the todayGoalMet and todayCount
    /// properties.
    ///
    /// **Why do days with no puffs break the streak?**
    /// A day with no logged puffs (0 puffs) is treated as a missed day that breaks the
    /// streak. This maintains data integrity - if you weren't tracking, the streak doesn't
    /// continue. This encourages consistent daily tracking.
    ///
    /// - Parameters:
    ///   - dailyGoal: The target number of puffs per day (from @AppStorage)
    ///   - storedBestStreak: The previously stored best streak (from @AppStorage)
    /// - Returns: A StreakInfo struct containing all calculated streak data
    ///
    /// **Example usage:**
    /// ```swift
    /// let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 5)
    /// print("Current streak: \(info.currentStreak) days")
    /// print("Best streak: \(info.bestStreak) days")
    /// ```
    func calculateStreak(dailyGoal: Int, storedBestStreak: Int) -> StreakInfo {
        // Edge case: No goal set
        // If dailyGoal is 0 or negative, there's no goal to track against.
        // Return a zero streak but preserve the stored best streak.
        guard dailyGoal > 0 else {
            return StreakInfo(
                currentStreak: 0,
                bestStreak: storedBestStreak,
                todayGoalMet: false,
                todayCount: 0
            )
        }

        let calendar = Calendar.current
        let today = Date()

        // Group puffs by day using the existing groupedByDay() method from PuffGrouping.
        // This reuses our well-tested date normalization logic.
        let groups = self.groupedByDay()

        // Edge case: No data at all (first time using the app)
        // If there are no puff groups, return zero streak with todayGoalMet = false
        guard !groups.isEmpty else {
            return StreakInfo(
                currentStreak: 0,
                bestStreak: storedBestStreak,
                todayGoalMet: false,  // Haven't started tracking yet
                todayCount: 0
            )
        }

        // Find today's group and calculate today's status
        let todayGroup = groups.first { $0.isToday }
        let todayCount = todayGroup?.count ?? 0
        // Goal is met if puff count is at or below the limit
        // If todayGroup is nil but we have historical data, assume 0 puffs (goal met)
        // If todayGroup exists, check if count <= goal
        let todayGoalMet = todayCount <= dailyGoal

        // Calculate the current streak by walking backward through days
        var currentStreak = 0

        // Start from today if goal is met, otherwise start from yesterday
        // This ensures we don't count incomplete days in the streak
        var checkDate = calendar.startOfDay(for: today)
        if !todayGoalMet {
            // Move to yesterday since today doesn't count yet
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        // Find the earliest puff date to know when tracking started
        // We use this to distinguish between "no data because tracking hasn't started"
        // and "no data because user didn't log anything that day"
        let earliestPuffDate = groups.map { $0.date }.min() ?? today

        // Walk backward through days, counting consecutive days that met the goal
        // If todayGoalMet is true, we start from today and count it in the loop
        // If todayGoalMet is false, we start from yesterday and count from there
        while true {
            let normalizedCheckDate = calendar.startOfDay(for: checkDate)

            // Find the group for this specific day
            let group = groups.first {
                calendar.isDate($0.date, inSameDayAs: normalizedCheckDate)
            }

            if let group = group {
                // We have data for this day
                if group.count <= dailyGoal {
                    // Goal was met! Increment streak and continue backward
                    currentStreak += 1
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                } else {
                    // Goal was exceeded (not met). Streak is broken.
                    break
                }
            } else {
                // No data for this day
                // Check if this is before tracking started or a genuinely missed day
                if normalizedCheckDate < calendar.startOfDay(for: earliestPuffDate) {
                    // This is before we started tracking. Stop here.
                    break
                } else {
                    // This is a day with no puffs logged (missed day). Streak is broken.
                    break
                }
            }
        }

        // Calculate the new best streak
        // If the current streak exceeds the stored best, update it
        // We use Swift.max() to explicitly reference the global function (not Array's max)
        let newBestStreak = Swift.max(currentStreak, storedBestStreak)

        return StreakInfo(
            currentStreak: currentStreak,
            bestStreak: newBestStreak,
            todayGoalMet: todayGoalMet,
            todayCount: todayCount
        )
    }
}

// MARK: - Educational Notes
//
// **Why use a computed property pattern in ContentView?**
// By making streakInfo a computed property that calls calculateStreak(), it automatically
// recalculates whenever puffs or dailyPuffGoal changes. This ensures the UI always shows
// the current streak without manual updates.
//
// **Why pass storedBestStreak as a parameter?**
// This maintains separation of concerns. The calculation logic doesn't need to know about
// @AppStorage or UserDefaults. It receives the stored value and returns the new value,
// letting ContentView handle the persistence.
//
// **Performance considerations:**
// The groupedByDay() call is O(n) where n is the number of puffs. The backward date walk
// is O(d) where d is the number of days. For typical usage (hundreds of puffs over months),
// this is very fast and can be called on every UI update without performance issues.
//
// **Why use calendar.startOfDay()?**
// Dates include time components down to the nanosecond. By normalizing to startOfDay,
// we ensure accurate day-to-day comparisons regardless of the specific time a puff was logged.
// This is critical for correct streak counting across midnight boundaries.
//
// **Timezone handling:**
// Using Calendar.current ensures all date calculations respect the user's timezone.
// If a user travels across timezones, the calendar adjusts automatically, keeping
// streak calculations accurate to local time.
//
