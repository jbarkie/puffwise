//
//  ReductionPlan.swift
//  Puffwise
//
//  Defines a compounding weekly puff-reduction plan and the calculations
//  that drive the dynamic daily goal shown in ContentView.
//

import Foundation

// MARK: - ReductionPlan

/// A snapshot of the user's reduction configuration, persisted as JSON in UserDefaults.
///
/// **Compounding reduction:**
/// Each week the daily goal is multiplied by (1 − rate), so reductions grow smaller
/// as the goal approaches the floor — easier to sustain than a fixed weekly cut.
///
/// **Effective daily goal:**
/// Rather than showing the same number every day of the week, the plan divides the
/// remaining weekly budget by the days still left (including today). Logging fewer
/// puffs early in the week rewards the user with a higher allowance later; logging
/// more tightens it. This makes the reduction feel responsive rather than arbitrary.
struct ReductionPlan: Codable {

    /// The date the plan was first activated (used as the epoch for week offsets).
    let startDate: Date

    /// The daily goal at the moment the plan was activated.
    let startingGoal: Int

    /// Percentage to compound off the remaining goal each week (1–20).
    let weeklyReductionPercent: Double

    /// The daily goal will never be reduced below this value.
    let minimumFloor: Int

    // MARK: - Core Calculations

    /// Computes the daily puff goal for a given number of weeks after the start week.
    ///
    /// Formula: `startingGoal × (1 − rate)^weeks`, clamped to `minimumFloor`.
    /// Week 0 equals the starting goal (no reduction has occurred yet).
    func weeklyTarget(forWeekOffset weeks: Int) -> Int {
        guard weeks >= 0 else { return startingGoal }
        let factor = pow(1.0 - weeklyReductionPercent / 100.0, Double(weeks))
        let raw = Double(startingGoal) * factor
        return max(Int(raw.rounded()), minimumFloor)
    }

    /// Daily puff goal for the current calendar week.
    func currentWeekTarget() -> Int {
        weeklyTarget(forWeekOffset: weeksElapsed())
    }

    /// Dynamic daily allowance that accounts for puffs already logged this week.
    ///
    /// Spreads the remaining weekly budget across the days still left in the week,
    /// including today, then caps the result at the weekly target's daily rate.
    /// The cap ensures that logging fewer puffs than expected earlier in the week
    /// does not inflate today's allowance above the intended daily limit — unused
    /// budget is discarded rather than rolled forward.
    ///
    /// When the plan is paused (user exceeded last week's target), the weekly budget
    /// is based on the previous week's target rather than the scheduled reduction,
    /// so no further tightening is applied until the user gets back on track.
    ///
    /// - Parameters:
    ///   - puffsThisWeek: Total puffs logged since the start of the current week.
    ///   - puffsLastWeek: Total puffs logged during the previous calendar week.
    ///                    Defaults to 0 (never paused) for backward compatibility.
    func effectiveDailyGoal(puffsThisWeek: Int, puffsLastWeek: Int = 0) -> Int {
        let dailyTarget = isPausedThisWeek(puffsLastWeek: puffsLastWeek)
            ? pausedWeekTarget(puffsLastWeek: puffsLastWeek)
            : currentWeekTarget()
        let weeklyBudget = dailyTarget * 7
        // When the weekly budget is already exhausted, the daily target hasn't changed —
        // the user is simply over budget. Return dailyTarget so the display remains
        // meaningful rather than showing "of 0 puffs".
        guard puffsThisWeek < weeklyBudget else { return dailyTarget }
        let remaining = weeklyBudget - puffsThisWeek
        let daysLeft = daysRemainingInCurrentWeek()
        let raw = Int(ceil(Double(remaining) / Double(daysLeft)))
        return max(0, min(raw, dailyTarget))
    }

    // MARK: - Date Helpers

    /// Whole weeks elapsed from the week containing `startDate` to the current week.
    func weeksElapsed() -> Int {
        let cal = Calendar.current
        let startWeekStart = cal.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
        let currentWeekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let days = cal.dateComponents([.day], from: startWeekStart, to: currentWeekStart).day ?? 0
        return max(0, days / 7)
    }

    /// Calendar days remaining in the current week, including today.
    ///
    /// Uses the device locale's first-weekday setting (e.g. Sunday or Monday),
    /// so "end of week" matches what the user sees in Calendar.app.
    func daysRemainingInCurrentWeek() -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let weekEnd = cal.dateInterval(of: .weekOfYear, for: today)?.end else { return 1 }
        // `weekEnd` is the exclusive start of the next week, so the difference in
        // whole days equals the number of remaining days including today.
        let days = cal.dateComponents([.day], from: today, to: weekEnd).day ?? 1
        return max(1, days)
    }

    /// The date when the next weekly reduction will take effect (start of next week).
    func nextReductionDate() -> Date {
        Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.end
            ?? Date().addingTimeInterval(7 * 24 * 3600)
    }

    /// The date interval for the calendar week immediately before the current one.
    func previousWeekInterval() -> DateInterval? {
        let cal = Calendar.current
        guard let currentStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start,
              let prevWeekDate = cal.date(byAdding: .weekOfYear, value: -1, to: currentStart)
        else { return nil }
        return cal.dateInterval(of: .weekOfYear, for: prevWeekDate)
    }

    /// True when the plan should hold this week's target at the previous week's level.
    ///
    /// A pause occurs when at least one full week has elapsed AND the user's total
    /// puffs for the previous calendar week exceeded that week's daily target × 7.
    /// Week 0 is never paused — there is no prior week to evaluate.
    ///
    /// - Parameter puffsLastWeek: Total puffs logged during the previous calendar week.
    func isPausedThisWeek(puffsLastWeek: Int) -> Bool {
        let elapsed = weeksElapsed()
        guard elapsed > 0 else { return false }
        let prevTarget = weeklyTarget(forWeekOffset: elapsed - 1)
        return puffsLastWeek > prevTarget * 7
    }

    /// The daily target to hold when the plan is paused (previous week's scheduled target).
    ///
    /// - Parameter puffsLastWeek: Total puffs logged during the previous calendar week.
    func pausedWeekTarget(puffsLastWeek: Int) -> Int {
        let elapsed = weeksElapsed()
        guard elapsed > 0 else { return currentWeekTarget() }
        return weeklyTarget(forWeekOffset: elapsed - 1)
    }

    // MARK: - Plan State

    /// True when the user has reached the minimum floor after meaningful reduction occurred.
    ///
    /// A plan where `startingGoal` already equals `minimumFloor` has no trajectory
    /// to complete, so it is never considered complete — only misconfigured.
    var isComplete: Bool {
        guard startingGoal > minimumFloor else { return false }
        let lastWeek = trajectoryPoints().last?.week ?? 0
        return weeksElapsed() >= lastWeek
    }

    // MARK: - Chart Data

    /// Generates goal trajectory points from week 0 until the floor is reached,
    /// capped at `maxWeeks` to keep the chart readable.
    ///
    /// - Parameter maxWeeks: Upper bound on the number of data points (default 26 ≈ 6 months).
    /// - Returns: Array of `(week, goal)` tuples suitable for a Swift Charts LineMark.
    func trajectoryPoints(maxWeeks: Int = 26) -> [(week: Int, goal: Int)] {
        var points: [(week: Int, goal: Int)] = []
        for week in 0...maxWeeks {
            let target = weeklyTarget(forWeekOffset: week)
            points.append((week: week, goal: target))
            if target <= minimumFloor { break }
        }
        return points
    }
}
