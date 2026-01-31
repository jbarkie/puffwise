//
//  CSVExporter.swift
//  Puffwise
//
//  Exports puff data to CSV format for backup and analysis.
//  Uses the same Array extension pattern as StatisticsCalculator.swift.
//

import Foundation

// MARK: - Array Extension for CSV Export

extension Array where Element == Puff {

    /// Exports puffs to CSV format for backup and analysis.
    ///
    /// The CSV includes:
    /// - Header with metadata (export date, total puffs, goal, date range)
    /// - Columns: timestamp_iso, date, time, day_of_week
    ///
    /// Puffs are sorted newest-first for easier reading of recent data.
    ///
    /// - Parameter dailyGoal: The user's current daily puff goal
    /// - Returns: A CSV string ready for export
    func exportToCSV(dailyGoal: Int) -> String {
        var lines: [String] = []

        // Sort puffs newest-first
        let sortedPuffs = self.sorted { $0.timestamp > $1.timestamp }

        // Generate header metadata
        lines.append("# Puffwise Export")
        lines.append("# Generated: \(Self.metadataDateFormatter.string(from: Date()))")
        lines.append("# Total Puffs: \(Self.numberFormatter.string(from: NSNumber(value: self.count)) ?? "\(self.count)")")
        lines.append("# Daily Goal: \(dailyGoal)")
        lines.append("# Date Range: \(dateRangeString())")
        lines.append("")

        // CSV column headers
        lines.append("timestamp_iso,date,time,day_of_week")

        // Data rows
        for puff in sortedPuffs {
            let iso8601 = Self.iso8601Formatter.string(from: puff.timestamp)
            let date = Self.dateFormatter.string(from: puff.timestamp)
            let time = Self.timeFormatter.string(from: puff.timestamp)
            let dayOfWeek = Self.dayOfWeekFormatter.string(from: puff.timestamp)

            lines.append("\(iso8601),\(date),\(time),\(dayOfWeek)")
        }

        return lines.joined(separator: "\n")
    }

    /// Generates the filename for export.
    ///
    /// Format: puffwise_export_YYYY-MM-DD.csv
    ///
    /// - Returns: A filename string with today's date
    static func exportFilename() -> String {
        let dateString = filenameDateFormatter.string(from: Date())
        return "puffwise_export_\(dateString).csv"
    }

    // MARK: - Private Helpers

    /// Generates a human-readable date range string.
    ///
    /// Uses minmax algorithm (O(n)) instead of sorting (O(n log n)) for better performance.
    ///
    /// - Returns: Date range (e.g., "January 1, 2025 - January 31, 2026")
    ///            or "No data" if the array is empty
    private func dateRangeString() -> String {
        // Use minmax to find oldest and newest in single pass (O(n))
        // This is more efficient than sorting the entire array
        guard let oldest = self.min(by: { $0.timestamp < $1.timestamp }),
              let newest = self.max(by: { $0.timestamp < $1.timestamp }) else {
            return "No data"
        }

        let oldestString = Self.dateFormatter.string(from: oldest.timestamp)
        let newestString = Self.dateFormatter.string(from: newest.timestamp)

        return "\(oldestString) - \(newestString)"
    }

    // MARK: - Static Formatters

    // DateFormatter creation is expensive, so we use static instances.
    // These are the same pattern used in PuffGrouping.swift.

    /// ISO 8601 formatter for machine-readable timestamps.
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// Human-readable date formatter (e.g., "January 31, 2026").
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    /// Human-readable time formatter (e.g., "9:30 AM").
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    /// Day of week formatter (e.g., "Friday").
    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    /// Metadata date formatter for the export header.
    private static let metadataDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()

    /// Filename date formatter (YYYY-MM-DD format).
    private static let filenameDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// Number formatter for comma-separated numbers.
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
}
