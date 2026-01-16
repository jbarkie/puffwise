//
//  StatisticsCalculator.swift
//  Puffwise
//
//  Calculates average puff statistics over time periods.
//  Uses the same Array extension pattern as PuffGrouping.swift.
//

import Foundation

// MARK: - StatisticsInfo

/// Holds calculated statistics for display.
/// Equatable conformance enables use in SwiftUI comparisons and tests.
struct StatisticsInfo: Equatable {
    /// Average puffs per day over the last 7 days.
    let sevenDayAverage: Double

    /// Average puffs per day over the last 30 days.
    let thirtyDayAverage: Double

    /// Whether there's enough data to show statistics (at least 1 day of data).
    var hasData: Bool {
        sevenDayAverage > 0 || thirtyDayAverage > 0
    }
}

// MARK: - Array Extension for Statistics

extension Array where Element == Puff {

    /// Calculates 7-day and 30-day average puffs per day.
    ///
    /// Uses groupedByDay() to organize puffs, then calculates averages
    /// for each time period. Days with no puffs within the period are
    /// not counted (only days with actual data contribute to the average).
    ///
    /// - Returns: StatisticsInfo with calculated averages
    func calculateStatistics() -> StatisticsInfo {
        let groups = self.groupedByDay()

        guard !groups.isEmpty else {
            return StatisticsInfo(sevenDayAverage: 0, thirtyDayAverage: 0)
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Calculate date boundaries (inclusive of today)
        // -6 days means: today + 6 previous days = 7 days total
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -29, to: today)!

        // Filter groups within each period
        let last7DaysGroups = groups.filter { $0.date >= sevenDaysAgo }
        let last30DaysGroups = groups.filter { $0.date >= thirtyDaysAgo }

        // Calculate averages (only over days with data)
        let sevenDayAvg = averageCount(for: last7DaysGroups)
        let thirtyDayAvg = averageCount(for: last30DaysGroups)

        return StatisticsInfo(
            sevenDayAverage: sevenDayAvg,
            thirtyDayAverage: thirtyDayAvg
        )
    }

    /// Helper to calculate average puff count across groups.
    private func averageCount(for groups: [PuffGroup]) -> Double {
        guard !groups.isEmpty else { return 0 }
        let total = groups.reduce(0) { $0 + $1.count }
        return Double(total) / Double(groups.count)
    }
}
