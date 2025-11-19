//
//  PuffGrouping.swift
//  Puffwise
//
//  Data grouping utilities for organizing puffs by time periods.
//  This file provides the logic to group puffs by day, week, or month
//  for display in the historical tracking view.
//

import Foundation

// MARK: - PuffGroupPeriod

/// Represents the different time periods by which puffs can be grouped.
///
/// This enum defines the three main grouping options for organizing puff data:
/// - **day**: Group puffs that occurred on the same calendar day
/// - **week**: Group puffs that occurred in the same week (using the user's calendar week definition)
/// - **month**: Group puffs that occurred in the same month
///
/// Using an enum here provides type safety and makes it easy to add new grouping
/// periods in the future (like year, hour, etc.) without changing the API.
enum PuffGroupPeriod {
    case day
    case week
    case month
}

// MARK: - PuffGroup

/// Represents a collection of puffs that occurred during a specific time period.
///
/// A PuffGroup bundles together:
/// - All puffs that fall within a specific time period (day/week/month)
/// - The date that represents this group (typically the start of the period)
/// - Computed properties for easy access to group statistics
///
/// This struct conforms to Identifiable so it can be used directly in SwiftUI Lists.
/// The id is the date's timeIntervalSince1970, which uniquely identifies each group.
struct PuffGroup: Identifiable {
    /// Unique identifier based on the date's timestamp.
    /// Using timeIntervalSince1970 ensures each time period has a unique ID.
    var id: TimeInterval {
        date.timeIntervalSince1970
    }

    /// The date representing this group (e.g., the start of the day/week/month).
    /// This is used for sorting groups and displaying the group's label.
    let date: Date

    /// All puffs that belong to this time period.
    let puffs: [Puff]

    /// The total number of puffs in this group.
    /// This computed property provides convenient access to the count.
    var count: Int {
        puffs.count
    }

    /// Indicates whether this group represents today's data.
    /// Useful for highlighting the current day in the UI.
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Array Extension for Grouping

/// Extension on Array where elements are Puff objects.
///
/// This extension adds grouping functionality directly to arrays of Puff objects,
/// making the API very natural: puffs.groupedBy(.day)
///
/// Extensions are a powerful Swift feature that lets us add methods to existing types
/// without modifying their original implementation. The `where Element == Puff` constraint
/// means these methods are only available on arrays containing Puff objects.
extension Array where Element == Puff {

    /// Groups puffs by the specified time period and returns an array of PuffGroup objects.
    ///
    /// This is the main grouping method that:
    /// 1. Iterates through all puffs
    /// 2. Determines which time period each puff belongs to
    /// 3. Groups puffs together that share the same period
    /// 4. Returns an array of PuffGroup objects, sorted from most recent to oldest
    ///
    /// - Parameter period: The time period to group by (.day, .week, or .month)
    /// - Returns: An array of PuffGroup objects, sorted with newest groups first
    ///
    /// **Example usage:**
    /// ```swift
    /// let puffs: [Puff] = [...]
    /// let dailyGroups = puffs.groupedBy(.day)
    /// let weeklyGroups = puffs.groupedBy(.week)
    /// ```
    ///
    /// **How it works:**
    /// The method uses a Dictionary to accumulate puffs by their normalized date.
    /// The normalized date represents the "start" of the time period (e.g., midnight
    /// for a day, first day of the week, first day of the month). All puffs within
    /// the same period get the same normalized date, so they end up in the same dictionary entry.
    func groupedBy(_ period: PuffGroupPeriod) -> [PuffGroup] {
        // Get the user's calendar (handles timezone, locale, week start day, etc.)
        let calendar = Calendar.current

        // Dictionary to accumulate puffs by their normalized date.
        // Key: The normalized date representing the start of the period
        // Value: Array of puffs that belong to this period
        var groupedPuffs: [Date: [Puff]] = [:]

        // Iterate through each puff and add it to the appropriate group
        for puff in self {
            // Normalize the puff's timestamp to the start of its time period
            let normalizedDate = normalizeDate(puff.timestamp, for: period, calendar: calendar)

            // Append this puff to the array for this normalized date.
            // If the key doesn't exist yet, create a new array with this puff.
            // If it does exist, append to the existing array.
            groupedPuffs[normalizedDate, default: []].append(puff)
        }

        // Convert the dictionary into an array of PuffGroup objects
        let groups = groupedPuffs.map { (date, puffs) in
            PuffGroup(date: date, puffs: puffs)
        }

        // Sort groups by date, most recent first.
        // This ensures the history view shows newest data at the top.
        return groups.sorted { $0.date > $1.date }
    }

    /// Groups puffs by day and returns an array of PuffGroup objects.
    ///
    /// This is a convenience method that's equivalent to `groupedBy(.day)`.
    /// It makes the API more readable when you know you specifically want daily grouping.
    ///
    /// - Returns: An array of PuffGroup objects representing days, sorted newest first
    func groupedByDay() -> [PuffGroup] {
        groupedBy(.day)
    }

    /// Groups puffs by week and returns an array of PuffGroup objects.
    ///
    /// This is a convenience method that's equivalent to `groupedBy(.week)`.
    /// Weeks are defined according to the user's calendar settings (which day starts the week).
    ///
    /// - Returns: An array of PuffGroup objects representing weeks, sorted newest first
    func groupedByWeek() -> [PuffGroup] {
        groupedBy(.week)
    }

    /// Groups puffs by month and returns an array of PuffGroup objects.
    ///
    /// This is a convenience method that's equivalent to `groupedBy(.month)`.
    ///
    /// - Returns: An array of PuffGroup objects representing months, sorted newest first
    func groupedByMonth() -> [PuffGroup] {
        groupedBy(.month)
    }

    // MARK: - Private Helper Methods

    /// Normalizes a date to the start of its time period.
    ///
    /// This is a crucial helper function that converts any date/time to the "start"
    /// of its respective time period. For example:
    /// - For a day: "2024-01-15 14:30:00" becomes "2024-01-15 00:00:00"
    /// - For a week: any date becomes the first day of that week at 00:00:00
    /// - For a month: "2024-01-15" becomes "2024-01-01 00:00:00"
    ///
    /// This normalization is what allows us to group puffs together - all puffs
    /// in the same period will have the same normalized date.
    ///
    /// - Parameters:
    ///   - date: The original date to normalize
    ///   - period: The time period to normalize to
    ///   - calendar: The calendar to use for date calculations
    /// - Returns: The normalized date representing the start of the time period
    private func normalizeDate(_ date: Date, for period: PuffGroupPeriod, calendar: Calendar) -> Date {
        // Determine which date components to extract based on the period.
        // We always want to "zero out" the smaller units and keep the larger ones.
        let components: Set<Calendar.Component>

        switch period {
        case .day:
            // For daily grouping, keep year/month/day, zero out hour/minute/second
            components = [.year, .month, .day]

        case .week:
            // For weekly grouping, keep year and week-of-year
            // Note: weekOfYear is defined by the user's calendar (e.g., ISO weeks, US weeks)
            components = [.yearForWeekOfYear, .weekOfYear]

        case .month:
            // For monthly grouping, keep year and month, zero out day/hour/minute/second
            components = [.year, .month]
        }

        // Extract the relevant components from the date
        let dateComponents = calendar.dateComponents(components, from: date)

        // Create a new date from those components.
        // This effectively "rounds down" the date to the start of the period.
        // For example, if we only extract year/month/day, the resulting date will
        // have hour:0, minute:0, second:0 automatically.
        // The nil-coalescing operator (??) returns the original date if conversion fails,
        // though this should never happen in practice.
        return calendar.date(from: dateComponents) ?? date
    }
}

// MARK: - DateFormatter Extensions

/// Extension to provide common date formatters for displaying group labels.
///
/// These formatters are used to convert the PuffGroup's date into human-readable
/// strings for the UI (e.g., "January 15, 2024" or "Week of Jan 15").
///
/// Creating static formatters is more efficient than creating new ones each time,
/// because DateFormatter initialization is relatively expensive.
extension DateFormatter {

    /// A formatter for displaying day labels: "January 15, 2024"
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // e.g., "Jan 15, 2024"
        formatter.timeStyle = .none    // Don't show time
        return formatter
    }()

    /// A formatter for displaying week labels: "Week of Jan 15, 2024"
    static let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Week of' MMM d, yyyy"
        return formatter
    }()

    /// A formatter for displaying month labels: "January 2024"
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

// MARK: - Educational Notes
//
// **Why use Dictionary for grouping?**
// Dictionary lookups are O(1) on average, making the grouping algorithm O(n) where n is
// the number of puffs. Alternative approaches like nested loops would be O(n²).
//
// **Why normalize dates?**
// Dates include time components down to the nanosecond. Two puffs on the same day but
// different times would have different Date values. By normalizing to the start of the
// period, we ensure all puffs in the same period have identical Date keys in our dictionary.
//
// **Why use extensions?**
// Extensions let us add methods to existing types. By extending Array<Puff>, we can write
// clean, readable code like `puffs.groupedByDay()` instead of `PuffGrouper.group(puffs, by: .day)`.
// This is called a "fluent API" and is very common in Swift.
//
// **Why make formatters static?**
// DateFormatter is expensive to create. By making these formatters static, we create them
// once and reuse them throughout the app's lifetime. This is a common optimization pattern.
//
// **Understanding Calendar.Component:**
// Calendar components are the building blocks of dates (year, month, day, hour, etc.).
// By extracting only certain components and creating a new date from them, we effectively
// "round down" dates to the start of a period. This is more reliable than manual date math.
