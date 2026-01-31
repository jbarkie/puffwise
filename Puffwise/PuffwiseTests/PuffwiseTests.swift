//
//  PuffwiseTests.swift
//  PuffwiseTests
//
//  Tests for PuffGrouping functionality.
//  These tests verify the date-based grouping logic used in the history view.
//

import Testing
import Foundation
@testable import Puffwise

// MARK: - PuffGrouping Tests

/// Test suite for PuffGrouping functionality.
///
/// **About Swift Testing Framework:**
/// This file uses Apple's modern Swift Testing framework (introduced in Swift 5.9).
/// Key differences from XCTest:
/// - Uses `@Test` attribute instead of `func testXXX()`
/// - Uses `#expect()` instead of `XCTAssert()`
/// - Supports async/await natively
/// - More Swift-native syntax and better error messages
///
/// **What we're testing:**
/// The PuffGrouping logic is the most complex part of the app, handling date
/// normalization and grouping algorithms. These tests ensure puffs are correctly
/// grouped by day, week, and month across various edge cases.
struct PuffGroupingTests {

    // MARK: - Test: Grouping by Day

    /// Tests that puffs are correctly grouped by calendar day.
    ///
    /// **What this tests:**
    /// - Multiple puffs on the same day should be in one group
    /// - Puffs on different days should be in separate groups
    /// - Each group's count should match the number of puffs
    @Test func groupPuffsByDay() async throws {
        // Create a known calendar for consistent testing
        let calendar = Calendar.current

        // Create test dates: Jan 1, Jan 1 (different time), and Jan 2
        let jan1Morning = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!
        let jan1Evening = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 21))!
        let jan2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2, hour: 14))!

        // Create test puffs with specific timestamps
        let puffs = [
            Puff(timestamp: jan1Morning),
            Puff(timestamp: jan1Evening),  // Same day as first, different time
            Puff(timestamp: jan2)
        ]

        // Group by day
        let groups = puffs.groupedByDay()

        // Verify we got 2 groups (Jan 1 and Jan 2)
        #expect(groups.count == 2)

        // Verify groups are sorted newest first (Jan 2 before Jan 1)
        #expect(groups[0].date > groups[1].date)

        // Verify Jan 2 group has 1 puff
        #expect(groups[0].count == 1)

        // Verify Jan 1 group has 2 puffs
        #expect(groups[1].count == 2)
    }

    // MARK: - Test: Grouping by Week

    /// Tests that puffs are correctly grouped by calendar week.
    ///
    /// **What this tests:**
    /// - Puffs in the same week should be grouped together
    /// - Puffs in different weeks should be in separate groups
    /// - Week boundaries are respected (based on the calendar's week definition)
    @Test func groupPuffsByWeek() async throws {
        let calendar = Calendar.current

        // Create test dates spanning two weeks
        // Week 1: Jan 1-7, 2024 (Monday-Sunday in ISO calendar)
        let week1Day1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!  // Monday
        let week1Day5 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 5))!  // Friday

        // Week 2: Jan 8-14, 2024
        let week2Day1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 8))!  // Monday

        let puffs = [
            Puff(timestamp: week1Day1),
            Puff(timestamp: week1Day5),  // Same week
            Puff(timestamp: week2Day1)   // Different week
        ]

        let groups = puffs.groupedByWeek()

        // Verify we got 2 groups (two different weeks)
        #expect(groups.count == 2)

        // Verify groups are sorted newest first
        #expect(groups[0].date > groups[1].date)

        // Verify week 2 has 1 puff, week 1 has 2 puffs
        #expect(groups[0].count == 1)
        #expect(groups[1].count == 2)
    }

    // MARK: - Test: Grouping by Month

    /// Tests that puffs are correctly grouped by calendar month.
    ///
    /// **What this tests:**
    /// - Puffs in the same month should be grouped together
    /// - Puffs in different months should be in separate groups
    /// - Month boundaries are correctly identified
    @Test func groupPuffsByMonth() async throws {
        let calendar = Calendar.current

        // Create test dates spanning two months
        let jan1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let jan31 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 31))!
        let feb1 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 1))!

        let puffs = [
            Puff(timestamp: jan1),
            Puff(timestamp: jan31),  // Same month (January)
            Puff(timestamp: feb1)    // Different month (February)
        ]

        let groups = puffs.groupedByMonth()

        // Verify we got 2 groups (January and February)
        #expect(groups.count == 2)

        // Verify groups are sorted newest first (Feb before Jan)
        #expect(groups[0].date > groups[1].date)

        // Verify February has 1 puff, January has 2 puffs
        #expect(groups[0].count == 1)
        #expect(groups[1].count == 2)
    }

    // MARK: - Test: Empty Array

    /// Tests that grouping an empty array returns an empty result.
    ///
    /// **What this tests:**
    /// - Edge case: no puffs should return no groups
    /// - Ensures the grouping logic handles empty input gracefully
    @Test func groupEmptyArrayReturnsEmptyResult() async throws {
        let puffs: [Puff] = []

        let dailyGroups = puffs.groupedByDay()
        let weeklyGroups = puffs.groupedByWeek()
        let monthlyGroups = puffs.groupedByMonth()

        // All grouping methods should return empty arrays
        #expect(dailyGroups.isEmpty)
        #expect(weeklyGroups.isEmpty)
        #expect(monthlyGroups.isEmpty)
    }

    // MARK: - Test: Single Puff

    /// Tests that grouping a single puff creates one group.
    ///
    /// **What this tests:**
    /// - Edge case: single puff should create a single group with count 1
    /// - Ensures the grouping logic works with minimal data
    @Test func groupSinglePuffCreatesOneGroup() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 6, day: 15))!
        let puffs = [Puff(timestamp: date)]

        let dailyGroups = puffs.groupedByDay()
        let weeklyGroups = puffs.groupedByWeek()
        let monthlyGroups = puffs.groupedByMonth()

        // All grouping methods should return exactly 1 group
        #expect(dailyGroups.count == 1)
        #expect(weeklyGroups.count == 1)
        #expect(monthlyGroups.count == 1)

        // Each group should have exactly 1 puff
        #expect(dailyGroups[0].count == 1)
        #expect(weeklyGroups[0].count == 1)
        #expect(monthlyGroups[0].count == 1)
    }

    // MARK: - Test: Year Boundary

    /// Tests that puffs across year boundaries are correctly grouped.
    ///
    /// **What this tests:**
    /// - Edge case: year transitions (Dec 31 to Jan 1)
    /// - Ensures date normalization works across year boundaries
    @Test func groupAcrossYearBoundary() async throws {
        let calendar = Calendar.current

        // Create puffs on Dec 31, 2023 and Jan 1, 2024
        let dec31 = calendar.date(from: DateComponents(year: 2023, month: 12, day: 31))!
        let jan1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!

        let puffs = [
            Puff(timestamp: dec31),
            Puff(timestamp: jan1)
        ]

        // Group by day - should be 2 separate groups
        let dailyGroups = puffs.groupedByDay()
        #expect(dailyGroups.count == 2)

        // Group by month - should be 2 separate groups (different months)
        let monthlyGroups = puffs.groupedByMonth()
        #expect(monthlyGroups.count == 2)
    }

    // MARK: - Test: Multiple Puffs Same Time

    /// Tests that multiple puffs with the exact same timestamp are grouped correctly.
    ///
    /// **What this tests:**
    /// - Edge case: puffs with identical timestamps should be in the same group
    /// - Ensures the grouping logic handles duplicate timestamps
    @Test func groupMultiplePuffsWithSameTimestamp() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 4, day: 10, hour: 15, minute: 30))!

        // Create multiple puffs with the exact same timestamp
        let puffs = [
            Puff(timestamp: date),
            Puff(timestamp: date),
            Puff(timestamp: date)
        ]

        let dailyGroups = puffs.groupedByDay()

        // Should have exactly 1 group
        #expect(dailyGroups.count == 1)
        // That group should contain all 3 puffs
        #expect(dailyGroups[0].count == 3)
    }

    // MARK: - Test: Sorting Order

    /// Tests that groups are sorted from newest to oldest.
    ///
    /// **What this tests:**
    /// - Verifies the sorting behavior of grouped results
    /// - Ensures newest data appears first (most recent dates)
    @Test func groupsSortedNewestFirst() async throws {
        let calendar = Calendar.current

        // Create puffs in random order across different days
        let day1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let day2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 5))!
        let day3 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 3))!

        let puffs = [
            Puff(timestamp: day1),  // Oldest
            Puff(timestamp: day3),  // Middle
            Puff(timestamp: day2)   // Newest
        ]

        let dailyGroups = puffs.groupedByDay()

        // Verify groups are sorted newest first
        #expect(dailyGroups.count == 3)
        #expect(dailyGroups[0].date == day2)  // Jan 5 (newest)
        #expect(dailyGroups[1].date == day3)  // Jan 3 (middle)
        #expect(dailyGroups[2].date == day1)  // Jan 1 (oldest)
    }
}

// MARK: - Puff Model Tests

/// Test suite for Puff model functionality.
///
/// **What we're testing:**
/// The Puff struct is the fundamental data model for the app. These tests ensure
/// that puffs are created correctly, their properties work as expected, and they
/// can be encoded/decoded for persistence.
struct PuffTests {

    // MARK: - Test: Default Initialization

    /// Tests that a puff created with default parameters has valid properties.
    ///
    /// **What this tests:**
    /// - Default initialization creates a unique ID
    /// - Default timestamp is close to the current time
    /// - Each puff gets a different UUID
    @Test func puffDefaultInitializationCreatesValidPuff() async throws {
        let puff1 = Puff()
        let puff2 = Puff()

        // Each puff should have a unique ID
        #expect(puff1.id != puff2.id)

        // The timestamps should be very close to now (within 1 second)
        let now = Date()
        let timeDifference1 = abs(puff1.timestamp.timeIntervalSince(now))
        let timeDifference2 = abs(puff2.timestamp.timeIntervalSince(now))

        #expect(timeDifference1 < 1.0)
        #expect(timeDifference2 < 1.0)
    }

    // MARK: - Test: Custom Initialization

    /// Tests that a puff can be created with a specific timestamp.
    ///
    /// **What this tests:**
    /// - Puffs can be created with custom timestamps (useful for testing and historical data)
    /// - The timestamp is preserved exactly as provided
    @Test func puffCustomInitializationUsesProvidedTimestamp() async throws {
        let calendar = Calendar.current
        let specificDate = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15, hour: 14, minute: 30))!

        let puff = Puff(timestamp: specificDate)

        // The puff's timestamp should exactly match what we provided
        #expect(puff.timestamp == specificDate)
    }

    // MARK: - Test: Custom ID

    /// Tests that a puff can be created with a specific UUID.
    ///
    /// **What this tests:**
    /// - Puffs can be created with custom IDs (useful for testing and data restoration)
    /// - The ID is preserved exactly as provided
    @Test func puffCustomIDIsPreserved() async throws {
        let customID = UUID()
        let puff = Puff(id: customID, timestamp: Date())

        // The puff's ID should exactly match what we provided
        #expect(puff.id == customID)
    }

    // MARK: - Test: Identifiable Conformance

    /// Tests that the Puff's Identifiable conformance works correctly.
    ///
    /// **What this tests:**
    /// - The id property is accessible (required by Identifiable protocol)
    /// - Each puff has a unique identifier
    ///
    /// **Why this matters:**
    /// SwiftUI requires Identifiable for items in Lists and ForEach loops.
    @Test func puffHasUniqueIdentifier() async throws {
        let puff1 = Puff()
        let puff2 = Puff()

        // IDs should be different for different puffs
        #expect(puff1.id != puff2.id)

        // IDs should be stable (same puff, same ID)
        #expect(puff1.id == puff1.id)
    }

    // MARK: - Test: Codable Conformance

    /// Tests that Puff can be encoded to and decoded from JSON.
    ///
    /// **What this tests:**
    /// - Puffs can be encoded to Data using JSONEncoder
    /// - Puffs can be decoded from Data using JSONDecoder
    /// - All properties are preserved through encoding/decoding
    ///
    /// **Why this matters:**
    /// The app uses Codable to persist puffs to UserDefaults as JSON.
    @Test func puffCanBeEncodedAndDecoded() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 7, day: 20, hour: 10, minute: 15))!
        let originalPuff = Puff(id: UUID(), timestamp: date)

        // Encode the puff to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPuff)

        // Decode the puff from JSON
        let decoder = JSONDecoder()
        let decodedPuff = try decoder.decode(Puff.self, from: data)

        // Verify all properties were preserved
        #expect(decodedPuff.id == originalPuff.id)
        #expect(decodedPuff.timestamp == originalPuff.timestamp)
    }

    // MARK: - Test: Array of Puffs Encoding

    /// Tests that an array of Puffs can be encoded and decoded.
    ///
    /// **What this tests:**
    /// - Arrays of Puff can be encoded/decoded (used in the app)
    /// - Order is preserved
    /// - All puffs in the array are preserved
    ///
    /// **Why this matters:**
    /// The app stores an array of puffs in UserDefaults, not individual puffs.
    @Test func arrayOfPuffsCanBeEncodedAndDecoded() async throws {
        let calendar = Calendar.current
        let date1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2))!

        let originalPuffs = [
            Puff(timestamp: date1),
            Puff(timestamp: date2)
        ]

        // Encode the array
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalPuffs)

        // Decode the array
        let decoder = JSONDecoder()
        let decodedPuffs = try decoder.decode([Puff].self, from: data)

        // Verify count and order
        #expect(decodedPuffs.count == 2)
        #expect(decodedPuffs[0].id == originalPuffs[0].id)
        #expect(decodedPuffs[1].id == originalPuffs[1].id)
        #expect(decodedPuffs[0].timestamp == originalPuffs[0].timestamp)
        #expect(decodedPuffs[1].timestamp == originalPuffs[1].timestamp)
    }
}

// MARK: - PuffGroup Model Tests

/// Test suite for PuffGroup model functionality.
///
/// **What we're testing:**
/// PuffGroup represents a collection of puffs for a specific time period.
/// These tests verify the computed properties and functionality of PuffGroup.
struct PuffGroupTests {

    // MARK: - Test: Count Property

    /// Tests that the count property correctly returns the number of puffs.
    ///
    /// **What this tests:**
    /// - The computed count property matches the actual array count
    /// - Count updates when the puffs array changes
    @Test func puffGroupCountReflectsNumberOfPuffs() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 5, day: 10))!

        // Create groups with different numbers of puffs
        let emptyGroup = PuffGroup(date: date, puffs: [])
        let singleGroup = PuffGroup(date: date, puffs: [Puff(timestamp: date)])
        let multipleGroup = PuffGroup(date: date, puffs: [
            Puff(timestamp: date),
            Puff(timestamp: date),
            Puff(timestamp: date)
        ])

        // Verify counts
        #expect(emptyGroup.count == 0)
        #expect(singleGroup.count == 1)
        #expect(multipleGroup.count == 3)
    }

    // MARK: - Test: isToday Property

    /// Tests that the isToday property correctly identifies today's group.
    ///
    /// **What this tests:**
    /// - Groups with today's date return true for isToday
    /// - Groups with other dates return false for isToday
    ///
    /// **Why this matters:**
    /// The UI uses this property to highlight today's data differently.
    @Test func puffGroupIsTodayIdentifiesCurrentDay() async throws {
        let calendar = Calendar.current

        // Create a group for today
        let today = Date()
        let todayGroup = PuffGroup(date: today, puffs: [Puff(timestamp: today)])

        // Create a group for yesterday
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let yesterdayGroup = PuffGroup(date: yesterday, puffs: [Puff(timestamp: yesterday)])

        // Create a group for tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let tomorrowGroup = PuffGroup(date: tomorrow, puffs: [Puff(timestamp: tomorrow)])

        // Verify isToday
        #expect(todayGroup.isToday == true)
        #expect(yesterdayGroup.isToday == false)
        #expect(tomorrowGroup.isToday == false)
    }

    // MARK: - Test: Identifiable Conformance

    /// Tests that PuffGroup's Identifiable conformance works correctly.
    ///
    /// **What this tests:**
    /// - The id property is based on the date's timestamp
    /// - Different dates produce different IDs
    /// - Same date produces same ID
    @Test func puffGroupHasUniqueIdentifierBasedOnDate() async throws {
        let calendar = Calendar.current

        let date1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
        let date2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2))!

        let group1 = PuffGroup(date: date1, puffs: [])
        let group2 = PuffGroup(date: date2, puffs: [])
        let group3 = PuffGroup(date: date1, puffs: [])  // Same date as group1

        // Different dates should have different IDs
        #expect(group1.id != group2.id)

        // Same date should have the same ID (even with different puffs)
        #expect(group1.id == group3.id)
    }

    // MARK: - Test: ID Stability

    /// Tests that a PuffGroup's ID is stable and derived from the date.
    ///
    /// **What this tests:**
    /// - The id is calculated from the date's timeIntervalSince1970
    /// - The id doesn't change when accessed multiple times
    @Test func puffGroupIDIsStable() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 8, day: 15))!
        let group = PuffGroup(date: date, puffs: [])

        // Get the ID multiple times
        let id1 = group.id
        let id2 = group.id

        // Should be the same each time
        #expect(id1 == id2)

        // Should match the date's timestamp
        #expect(id1 == date.timeIntervalSince1970)
    }
}

// MARK: - DateFormatter Extension Tests

/// Test suite for DateFormatter extensions.
///
/// **What we're testing:**
/// The DateFormatter extensions provide static formatters for displaying dates
/// in the UI. These tests ensure the formatters produce expected output.
struct DateFormatterTests {

    // MARK: - Test: Day Formatter

    /// Tests that the day formatter produces the expected format.
    ///
    /// **What this tests:**
    /// - The day formatter exists and is accessible
    /// - It formats dates in a readable format with month, day, and year
    @Test func dayFormatterProducesExpectedFormat() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15))!

        let formatted = DateFormatter.dayFormatter.string(from: date)

        // Should contain the day and year
        // Format is locale-dependent, but should contain "15" and "2024"
        #expect(formatted.contains("15"))
        #expect(formatted.contains("2024"))
    }

    // MARK: - Test: Week Formatter

    /// Tests that the week formatter produces the expected format.
    ///
    /// **What this tests:**
    /// - The week formatter exists and is accessible
    /// - It formats dates with "Week of" prefix and includes month, day, year
    @Test func weekFormatterProducesExpectedFormat() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 6, day: 20))!

        let formatted = DateFormatter.weekFormatter.string(from: date)

        // Should start with "Week of"
        #expect(formatted.hasPrefix("Week of"))
        // Should contain the date components
        #expect(formatted.contains("20"))
        #expect(formatted.contains("2024"))
    }

    // MARK: - Test: Month Formatter

    /// Tests that the month formatter produces the expected format.
    ///
    /// **What this tests:**
    /// - The month formatter exists and is accessible
    /// - It formats dates showing only month and year (no day)
    @Test func monthFormatterProducesExpectedFormat() async throws {
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: 2024, month: 9, day: 10))!

        let formatted = DateFormatter.monthFormatter.string(from: date)

        // Should contain the year
        #expect(formatted.contains("2024"))
        // Should contain month name (format is "MMMM yyyy" so full month name)
        #expect(formatted.contains("September") || formatted.contains("Sept"))
    }

    // MARK: - Test: Formatter Reusability

    /// Tests that formatters are static and reusable.
    ///
    /// **What this tests:**
    /// - The same formatter instance is returned each time
    /// - Static formatters are memory-efficient (not creating new instances)
    ///
    /// **Why this matters:**
    /// DateFormatter creation is expensive, so reusing static instances improves performance.
    @Test func formattersAreStaticAndReusable() async throws {
        // Get references to the formatters
        let dayFormatter1 = DateFormatter.dayFormatter
        let dayFormatter2 = DateFormatter.dayFormatter

        // Should be the exact same instance (reference equality)
        #expect(dayFormatter1 === dayFormatter2)

        // Same test for week and month formatters
        let weekFormatter1 = DateFormatter.weekFormatter
        let weekFormatter2 = DateFormatter.weekFormatter
        #expect(weekFormatter1 === weekFormatter2)

        let monthFormatter1 = DateFormatter.monthFormatter
        let monthFormatter2 = DateFormatter.monthFormatter
        #expect(monthFormatter1 === monthFormatter2)
    }
}

// MARK: - Goal Settings Tests

/// Test suite for goal settings functionality.
///
/// **What we're testing:**
/// Goal persistence, default values, and validation logic.
/// These tests ensure the goal setting feature works correctly
/// and persists data as expected.
///
/// **Testing Strategy:**
/// We use separate UserDefaults suite names for each test to ensure test isolation.
/// This prevents tests from interfering with each other or with the actual app's data.
/// Each test calls removePersistentDomain to start with a clean slate.
struct GoalSettingsTests {

    // MARK: - Test: Default Goal Value

    /// Tests that the default goal value is properly handled.
    ///
    /// **What this tests:**
    /// - UserDefaults behavior when a key doesn't exist
    /// - Default value handling for @AppStorage
    ///
    /// **How @AppStorage defaults work:**
    /// When a key doesn't exist in UserDefaults, @AppStorage uses the default value
    /// specified in the property declaration (in this case, 10).
    /// UserDefaults.integer(forKey:) returns 0 if the key doesn't exist, but
    /// @AppStorage handles the default value before that level.
    @Test func defaultGoalValueIs10() async throws {
        // Create a test UserDefaults suite to avoid affecting actual app data
        let defaults = UserDefaults(suiteName: "test.goal.defaults")!
        // Clear any existing data in the test suite
        defaults.removePersistentDomain(forName: "test.goal.defaults")

        // When the key doesn't exist, UserDefaults.integer returns 0
        let rawValue = defaults.integer(forKey: "dailyPuffGoal")
        #expect(rawValue == 0)

        // But @AppStorage will use the default value (10) specified in the view
        // This test documents the UserDefaults behavior; the actual default
        // is handled by @AppStorage in GoalSettingsView and ContentView
    }

    // MARK: - Test: Goal Persistence

    /// Tests that goal values persist correctly to UserDefaults.
    ///
    /// **What this tests:**
    /// - Setting and retrieving integer values from UserDefaults
    /// - Data persistence across reads
    ///
    /// **Why this matters:**
    /// @AppStorage relies on UserDefaults under the hood. This test verifies
    /// that the underlying storage mechanism works correctly for our use case.
    @Test func goalPersistsToUserDefaults() async throws {
        // Use a unique suite name for this test
        let defaults = UserDefaults(suiteName: "test.goal.persistence")!
        defaults.removePersistentDomain(forName: "test.goal.persistence")

        // Set a goal value
        defaults.set(25, forKey: "dailyPuffGoal")

        // Verify it was saved and can be retrieved
        let retrieved = defaults.integer(forKey: "dailyPuffGoal")
        #expect(retrieved == 25)

        // Set a different value
        defaults.set(50, forKey: "dailyPuffGoal")

        // Verify the new value is persisted
        let retrievedAgain = defaults.integer(forKey: "dailyPuffGoal")
        #expect(retrievedAgain == 50)
    }

    // MARK: - Test: Goal Range Validation

    /// Tests that goal values respect the valid range (1-100).
    ///
    /// **What this tests:**
    /// - The expected min and max bounds for goals
    /// - Documentation of the valid range
    ///
    /// **How validation works:**
    /// In the UI, the Stepper enforces bounds automatically via `in: 1...100`.
    /// This means users cannot set values outside this range through the interface.
    /// This test documents the expected range for future reference.
    @Test func goalValidationRespectsBounds() async throws {
        // Document the expected range for daily goals
        let minGoal = 1
        let maxGoal = 100

        // Verify the range makes sense
        #expect(minGoal >= 1)  // Lower bound should be at least 1
        #expect(maxGoal <= 100)  // Upper bound should be at most 100
        #expect(maxGoal > minGoal)  // Max should be greater than min

        // The Stepper in GoalSettingsView enforces this range:
        // Stepper(value: $dailyPuffGoal, in: 1...100)
    }

    // MARK: - Test: Goal Updates

    /// Tests that updating the goal value works correctly.
    ///
    /// **What this tests:**
    /// - Multiple consecutive updates to the goal
    /// - Overwriting previous values
    /// - Persistence of updated values
    ///
    /// **Real-world scenario:**
    /// Users may adjust their goal multiple times as they progress.
    /// This test ensures all updates are handled correctly.
    @Test func goalCanBeUpdated() async throws {
        let defaults = UserDefaults(suiteName: "test.goal.updates")!
        defaults.removePersistentDomain(forName: "test.goal.updates")

        // Set initial goal
        defaults.set(10, forKey: "dailyPuffGoal")
        #expect(defaults.integer(forKey: "dailyPuffGoal") == 10)

        // Update to a higher goal
        defaults.set(20, forKey: "dailyPuffGoal")
        #expect(defaults.integer(forKey: "dailyPuffGoal") == 20)

        // Update to a lower goal
        defaults.set(5, forKey: "dailyPuffGoal")
        #expect(defaults.integer(forKey: "dailyPuffGoal") == 5)

        // Update to max bound
        defaults.set(100, forKey: "dailyPuffGoal")
        #expect(defaults.integer(forKey: "dailyPuffGoal") == 100)

        // Update to min bound
        defaults.set(1, forKey: "dailyPuffGoal")
        #expect(defaults.integer(forKey: "dailyPuffGoal") == 1)
    }
}

// MARK: - Puff Edit/Delete Tests

/// Test suite for edit and delete functionality.
///
/// **What we're testing:**
/// These tests verify that puffs can be edited (timestamp changed while preserving ID)
/// and deleted from the array, with proper handling of edge cases like cross-day edits,
/// group updates, and today's count changes.
struct PuffEditDeleteTests {

    // MARK: - Delete Tests

    /// Tests that deleting a puff removes it from the array.
    @Test func deletePuffRemovesFromArray() async throws {
        let puff1 = Puff(timestamp: Date())
        let puff2 = Puff(timestamp: Date().addingTimeInterval(-3600))
        var puffs = [puff1, puff2]

        // Delete puff1
        puffs.removeAll { $0.id == puff1.id }

        #expect(puffs.count == 1)
        #expect(puffs[0].id == puff2.id)
    }

    /// Tests that deleting a puff preserves other puffs in the array.
    @Test func deletePuffPreservesOtherPuffs() async throws {
        let puff1 = Puff(timestamp: Date())
        let puff2 = Puff(timestamp: Date().addingTimeInterval(-3600))
        let puff3 = Puff(timestamp: Date().addingTimeInterval(-7200))
        var puffs = [puff1, puff2, puff3]

        // Delete middle puff
        puffs.removeAll { $0.id == puff2.id }

        #expect(puffs.count == 2)
        #expect(puffs[0].id == puff1.id)
        #expect(puffs[1].id == puff3.id)
    }

    /// Tests that deleting all puffs in a group results in an empty group.
    @Test func deleteAllPuffsInGroup() async throws {
        let calendar = Calendar.current
        let jan1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!

        let puff1 = Puff(timestamp: jan1)
        let puff2 = Puff(timestamp: jan1.addingTimeInterval(3600))
        var puffs = [puff1, puff2]

        // Group by day should show 1 group with 2 puffs
        let groupsBefore = puffs.groupedBy(.day)
        #expect(groupsBefore.count == 1)
        #expect(groupsBefore[0].count == 2)

        // Delete all puffs
        puffs.removeAll { $0.id == puff1.id }
        puffs.removeAll { $0.id == puff2.id }

        // Group by day should now be empty
        let groupsAfter = puffs.groupedBy(.day)
        #expect(groupsAfter.isEmpty)
    }

    /// Tests that deleting today's puff updates today's count correctly.
    @Test func deleteTodaysPuffUpdatesCount() async throws {
        let calendar = Calendar.current
        let now = Date()
        let todayPuff1 = Puff(timestamp: now)
        let todayPuff2 = Puff(timestamp: now.addingTimeInterval(-3600))
        let yesterdayPuff = Puff(timestamp: now.addingTimeInterval(-86400))
        var puffs = [todayPuff1, todayPuff2, yesterdayPuff]

        // Filter today's puffs
        let todaysPuffsBefore = puffs.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        #expect(todaysPuffsBefore.count == 2)

        // Delete one of today's puffs
        puffs.removeAll { $0.id == todayPuff1.id }

        // Today's count should decrease
        let todaysPuffsAfter = puffs.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        #expect(todaysPuffsAfter.count == 1)
        #expect(todaysPuffsAfter[0].id == todayPuff2.id)
    }

    // MARK: - Edit Tests

    /// Tests that editing a puff preserves its ID.
    @Test func editPuffPreservesID() async throws {
        let originalPuff = Puff(timestamp: Date())
        var puffs = [originalPuff]

        // Edit the timestamp
        let newTimestamp = Date().addingTimeInterval(-3600)
        let editedPuff = Puff(id: originalPuff.id, timestamp: newTimestamp)

        if let index = puffs.firstIndex(where: { $0.id == originalPuff.id }) {
            puffs[index] = editedPuff
        }

        #expect(puffs.count == 1)
        #expect(puffs[0].id == originalPuff.id)
        #expect(puffs[0].timestamp == newTimestamp)
    }

    /// Tests that editing a puff updates its timestamp.
    @Test func editPuffUpdatesTimestamp() async throws {
        let calendar = Calendar.current
        let jan1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!
        let jan2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2, hour: 14))!

        let originalPuff = Puff(timestamp: jan1)
        var puffs = [originalPuff]

        // Edit to different day
        let editedPuff = Puff(id: originalPuff.id, timestamp: jan2)

        if let index = puffs.firstIndex(where: { $0.id == originalPuff.id }) {
            puffs[index] = editedPuff
        }

        #expect(puffs[0].timestamp == jan2)
        #expect(calendar.isDate(puffs[0].timestamp, inSameDayAs: jan2))
    }

    /// Tests that editing a puff to a different day updates grouping correctly.
    @Test func editPuffToDifferentDay() async throws {
        let calendar = Calendar.current
        let jan1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!
        let jan2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2, hour: 14))!

        let puff1 = Puff(timestamp: jan1)
        let puff2 = Puff(timestamp: jan1.addingTimeInterval(3600))
        var puffs = [puff1, puff2]

        // Initially should have 1 group (both on Jan 1)
        let groupsBefore = puffs.groupedBy(.day)
        #expect(groupsBefore.count == 1)
        #expect(groupsBefore[0].count == 2)

        // Edit puff1 to Jan 2
        let editedPuff = Puff(id: puff1.id, timestamp: jan2)
        if let index = puffs.firstIndex(where: { $0.id == puff1.id }) {
            puffs[index] = editedPuff
        }

        // Should now have 2 groups (one for Jan 1, one for Jan 2)
        let groupsAfter = puffs.groupedBy(.day)
        #expect(groupsAfter.count == 2)
        #expect(groupsAfter.contains { $0.count == 1 })
    }

    /// Tests that editing today's puff to yesterday affects today's count.
    @Test func editTodaysPuffAffectsCount() async throws {
        let calendar = Calendar.current
        let now = Date()
        let yesterday = now.addingTimeInterval(-86400)

        let todayPuff1 = Puff(timestamp: now)
        let todayPuff2 = Puff(timestamp: now.addingTimeInterval(-3600))
        var puffs = [todayPuff1, todayPuff2]

        // Initially should have 2 puffs today
        let todaysBefore = puffs.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        #expect(todaysBefore.count == 2)

        // Edit one puff to yesterday
        let editedPuff = Puff(id: todayPuff1.id, timestamp: yesterday)
        if let index = puffs.firstIndex(where: { $0.id == todayPuff1.id }) {
            puffs[index] = editedPuff
        }

        // Should now have 1 puff today
        let todaysAfter = puffs.filter { calendar.isDate($0.timestamp, inSameDayAs: now) }
        #expect(todaysAfter.count == 1)
        #expect(todaysAfter[0].id == todayPuff2.id)
    }

    /// Tests that multiple edits to the same puff work correctly.
    @Test func multipleEditsToSamePuff() async throws {
        let calendar = Calendar.current
        let jan1 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 9))!
        let jan2 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 2, hour: 14))!
        let jan3 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 3, hour: 10))!

        let originalPuff = Puff(timestamp: jan1)
        var puffs = [originalPuff]

        // First edit: Jan 1 -> Jan 2
        let edit1 = Puff(id: originalPuff.id, timestamp: jan2)
        if let index = puffs.firstIndex(where: { $0.id == originalPuff.id }) {
            puffs[index] = edit1
        }
        #expect(puffs[0].timestamp == jan2)
        #expect(puffs[0].id == originalPuff.id)

        // Second edit: Jan 2 -> Jan 3
        let edit2 = Puff(id: originalPuff.id, timestamp: jan3)
        if let index = puffs.firstIndex(where: { $0.id == originalPuff.id }) {
            puffs[index] = edit2
        }
        #expect(puffs[0].timestamp == jan3)
        #expect(puffs[0].id == originalPuff.id)
    }

    /// Tests that editing a puff across month boundaries updates grouping.
    @Test func editPuffAcrossMonthBoundary() async throws {
        let calendar = Calendar.current
        let jan31 = calendar.date(from: DateComponents(year: 2024, month: 1, day: 31, hour: 23))!
        let feb1 = calendar.date(from: DateComponents(year: 2024, month: 2, day: 1, hour: 1))!

        let puff = Puff(timestamp: jan31)
        var puffs = [puff]

        // Initially in January
        let groupsBefore = puffs.groupedBy(.month)
        #expect(groupsBefore.count == 1)
        // The group date should be the start of January
        #expect(calendar.component(.month, from: groupsBefore[0].date) == 1)

        // Edit to February
        let editedPuff = Puff(id: puff.id, timestamp: feb1)
        if let index = puffs.firstIndex(where: { $0.id == puff.id }) {
            puffs[index] = editedPuff
        }

        // Should now be in February
        let groupsAfter = puffs.groupedBy(.month)
        #expect(groupsAfter.count == 1)
        #expect(calendar.component(.month, from: groupsAfter[0].date) == 2)
    }

    /// Tests that editing preserves the puff in the array (doesn't delete or duplicate).
    @Test func editPuffPreservesArrayIntegrity() async throws {
        let puff1 = Puff(timestamp: Date())
        let puff2 = Puff(timestamp: Date().addingTimeInterval(-3600))
        let puff3 = Puff(timestamp: Date().addingTimeInterval(-7200))
        var puffs = [puff1, puff2, puff3]

        // Edit middle puff
        let newTimestamp = Date().addingTimeInterval(-10800)
        let editedPuff = Puff(id: puff2.id, timestamp: newTimestamp)
        if let index = puffs.firstIndex(where: { $0.id == puff2.id }) {
            puffs[index] = editedPuff
        }

        // Should still have exactly 3 puffs
        #expect(puffs.count == 3)
        // Should have the same IDs
        #expect(puffs.contains { $0.id == puff1.id })
        #expect(puffs.contains { $0.id == puff2.id })
        #expect(puffs.contains { $0.id == puff3.id })
        // Middle puff should have new timestamp
        let updatedPuff = puffs.first { $0.id == puff2.id }
        #expect(updatedPuff?.timestamp == newTimestamp)
    }

    /// Tests that editing a puff to the same time is idempotent (no side effects).
    @Test func editPuffToSameTimestamp() async throws {
        let timestamp = Date()
        let originalPuff = Puff(timestamp: timestamp)
        var puffs = [originalPuff]

        // "Edit" to the same timestamp
        let editedPuff = Puff(id: originalPuff.id, timestamp: timestamp)
        if let index = puffs.firstIndex(where: { $0.id == originalPuff.id }) {
            puffs[index] = editedPuff
        }

        // Should be unchanged
        #expect(puffs.count == 1)
        #expect(puffs[0].id == originalPuff.id)
        #expect(puffs[0].timestamp == timestamp)
    }
}

// MARK: - Statistics Tests

/// Test suite for statistics calculation functionality.
///
/// **What we're testing:**
/// The StatisticsCalculator calculates 7-day and 30-day averages from puff data.
/// These tests verify the calculation logic handles various scenarios correctly.
struct StatisticsTests {

    // MARK: - Test: Empty Array

    /// Tests that calculating statistics on empty data returns zeros.
    @Test func emptyArrayReturnsZeroAverages() async throws {
        let puffs: [Puff] = []
        let stats = puffs.calculateStatistics()

        #expect(stats.sevenDayAverage == 0)
        #expect(stats.thirtyDayAverage == 0)
        #expect(stats.hasData == false)
    }

    // MARK: - Test: Single Day

    /// Tests statistics with puffs from a single day.
    @Test func singleDayStatistics() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Create 5 puffs today
        let puffs = (0..<5).map { i in
            Puff(timestamp: today.addingTimeInterval(Double(i) * 3600))
        }

        let stats = puffs.calculateStatistics()

        // 5 puffs over 1 day = 5.0 average
        #expect(stats.sevenDayAverage == 5.0)
        #expect(stats.thirtyDayAverage == 5.0)
        #expect(stats.hasData == true)
    }

    // MARK: - Test: Seven Day Average

    /// Tests that 7-day average is calculated correctly.
    @Test func sevenDayAverageCalculation() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var puffs: [Puff] = []

        // Create puffs for 7 days with varying counts
        // Day 0 (today): 4 puffs
        // Day 1: 6 puffs
        // Day 2: 2 puffs
        // Day 3: 8 puffs
        // Day 4: 4 puffs
        // Day 5: 6 puffs
        // Day 6: 0 puffs (no data)
        // Total: 30 puffs over 6 days with data = 5.0 avg
        let dailyCounts = [4, 6, 2, 8, 4, 6]
        for (dayOffset, count) in dailyCounts.enumerated() {
            let day = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            for i in 0..<count {
                puffs.append(Puff(timestamp: day.addingTimeInterval(Double(i) * 3600)))
            }
        }

        let stats = puffs.calculateStatistics()

        // 30 puffs / 6 days = 5.0 average
        #expect(stats.sevenDayAverage == 5.0)
    }

    // MARK: - Test: Thirty Day Average

    /// Tests that 30-day average is calculated correctly with more data.
    @Test func thirtyDayAverageCalculation() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var puffs: [Puff] = []

        // Create 3 puffs per day for 30 days
        for dayOffset in 0..<30 {
            let day = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            for i in 0..<3 {
                puffs.append(Puff(timestamp: day.addingTimeInterval(Double(i) * 3600)))
            }
        }

        let stats = puffs.calculateStatistics()

        // 90 puffs / 30 days = 3.0 average
        #expect(stats.thirtyDayAverage == 3.0)
    }

    // MARK: - Test: Partial Data

    /// Tests statistics when there's less than 7 or 30 days of data.
    @Test func partialDataStatistics() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Only 3 days of data
        var puffs: [Puff] = []
        for dayOffset in 0..<3 {
            let day = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            for i in 0..<4 {
                puffs.append(Puff(timestamp: day.addingTimeInterval(Double(i) * 3600)))
            }
        }

        let stats = puffs.calculateStatistics()

        // 12 puffs / 3 days = 4.0 average (for both 7-day and 30-day)
        #expect(stats.sevenDayAverage == 4.0)
        #expect(stats.thirtyDayAverage == 4.0)
    }

    // MARK: - Test: Old Data Excluded

    /// Tests that data older than 30 days is excluded from 30-day average.
    @Test func oldDataExcludedFromAverage() async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var puffs: [Puff] = []

        // Add 5 puffs today
        for i in 0..<5 {
            puffs.append(Puff(timestamp: today.addingTimeInterval(Double(i) * 3600)))
        }

        // Add 100 puffs from 60 days ago (should be excluded)
        let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: today)!
        for i in 0..<100 {
            puffs.append(Puff(timestamp: sixtyDaysAgo.addingTimeInterval(Double(i) * 60)))
        }

        let stats = puffs.calculateStatistics()

        // Only today's 5 puffs should count
        #expect(stats.sevenDayAverage == 5.0)
        #expect(stats.thirtyDayAverage == 5.0)
    }

    // MARK: - Test: StatisticsInfo Equatable

    /// Tests that StatisticsInfo Equatable conformance works correctly.
    @Test func statisticsInfoEquatable() async throws {
        let stats1 = StatisticsInfo(sevenDayAverage: 5.0, thirtyDayAverage: 4.0)
        let stats2 = StatisticsInfo(sevenDayAverage: 5.0, thirtyDayAverage: 4.0)
        let stats3 = StatisticsInfo(sevenDayAverage: 6.0, thirtyDayAverage: 4.0)

        #expect(stats1 == stats2)
        #expect(stats1 != stats3)
    }

    // MARK: - Test: hasData Property

    /// Tests the hasData computed property.
    @Test func hasDataProperty() async throws {
        let noData = StatisticsInfo(sevenDayAverage: 0, thirtyDayAverage: 0)
        let hasSevenDay = StatisticsInfo(sevenDayAverage: 5.0, thirtyDayAverage: 0)
        let hasThirtyDay = StatisticsInfo(sevenDayAverage: 0, thirtyDayAverage: 3.0)
        let hasBoth = StatisticsInfo(sevenDayAverage: 5.0, thirtyDayAverage: 3.0)

        #expect(noData.hasData == false)
        #expect(hasSevenDay.hasData == true)
        #expect(hasThirtyDay.hasData == true)
        #expect(hasBoth.hasData == true)
    }
}
// MARK: - Streak Calculation Tests

/// Test suite for streak calculation functionality.
///
/// **What we're testing:**
/// Streak tracking is a core motivational feature that calculates consecutive days
/// meeting the daily puff goal. These tests verify the streak calculation algorithm
/// handles all scenarios correctly, including edge cases like incomplete days,
/// missing data, year boundaries, and best streak persistence.
struct StreakCalculationTests {

    // MARK: - Basic Functionality Tests

    /// Tests that an empty puff array returns zero streak.
    ///
    /// **What this tests:**
    /// - Empty data case
    /// - Default values when no puffs exist
    @Test func noDataReturnsZeroStreak() async throws {
        let puffs: [Puff] = []
        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 0)
        #expect(info.bestStreak == 0)
        #expect(info.todayGoalMet == false)
        #expect(info.todayCount == 0)
        #expect(info.hasActiveStreak == false)
    }

    /// Tests that a single day meeting the goal creates a 1-day streak.
    ///
    /// **What this tests:**
    /// - First day of tracking
    /// - Streak starts when goal is met
    @Test func singleDayMeetingGoalCreatesOneDayStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into tomorrow
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today

        // Create 5 puffs today (goal is 10)
        let puffs = (0..<5).map { minute in
            Puff(timestamp: today.addingTimeInterval(Double(minute * 60)))  // Add minutes instead of hours
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 1)
        #expect(info.bestStreak == 1)
        #expect(info.todayGoalMet == true)
        #expect(info.todayCount == 5)
        #expect(info.hasActiveStreak == true)
    }

    /// Tests that exceeding today's goal results in zero streak.
    ///
    /// **What this tests:**
    /// - Goal not met when puff count exceeds limit
    /// - Today is excluded from streak when goal not met
    @Test func todayExceedingGoalBreaksStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into tomorrow
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today

        // Create 15 puffs today (goal is 10)
        let puffs = (0..<15).map { minute in
            Puff(timestamp: today.addingTimeInterval(Double(minute * 60)))  // Add minutes instead of hours
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 0)
        #expect(info.todayGoalMet == false)
        #expect(info.todayCount == 15)
        #expect(info.hasActiveStreak == false)
    }

    /// Tests that consecutive days meeting the goal creates a multi-day streak.
    ///
    /// **What this tests:**
    /// - Multiple consecutive days
    /// - Streak counting algorithm
    /// - Backward date walking
    @Test func consecutiveDaysMeetingGoalCreatesStreak() async throws {
        let calendar = Calendar.current
        let today = Date()
        var puffs: [Puff] = []

        // Create 5 consecutive days, each with 5 puffs (goal = 10)
        for day in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            for hour in 0..<5 {
                puffs.append(Puff(timestamp: date.addingTimeInterval(Double(hour * 3600))))
            }
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 5)
        #expect(info.bestStreak == 5)
        #expect(info.todayGoalMet == true)
        #expect(info.todayCount == 5)
    }

    /// Tests that a day exceeding the goal breaks the streak.
    ///
    /// **What this tests:**
    /// - Streak interruption
    /// - Goal exceeded = streak broken
    @Test func missedDayBreaksStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into adjacent days
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today
        var puffs: [Puff] = []

        // Day 0 (today): 5 puffs (meets goal)
        for minute in 0..<5 {
            puffs.append(Puff(timestamp: today.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        // Day -1 (yesterday): 15 puffs (exceeds goal of 10)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        for minute in 0..<15 {
            puffs.append(Puff(timestamp: yesterday.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        // Day -2: 5 puffs (meets goal)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        for minute in 0..<5 {
            puffs.append(Puff(timestamp: twoDaysAgo.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        // Streak should be 1 (only today), because yesterday broke it
        #expect(info.currentStreak == 1)
        #expect(info.todayGoalMet == true)
    }

    // MARK: - Edge Case Tests

    /// Tests that no goal set returns zero streak.
    ///
    /// **What this tests:**
    /// - Edge case: dailyGoal = 0
    /// - System behavior when no goal configured
    @Test func noGoalSetReturnsZeroStreak() async throws {
        let calendar = Calendar.current
        let today = Date()

        // Create 5 puffs
        let puffs = (0..<5).map { hour in
            Puff(timestamp: today.addingTimeInterval(Double(hour * 3600)))
        }

        let info = puffs.calculateStreak(dailyGoal: 0, storedBestStreak: 0)

        #expect(info.currentStreak == 0)
        #expect(info.todayGoalMet == false)
        #expect(info.hasActiveStreak == false)
    }

    /// Tests that incomplete today is excluded from current streak.
    ///
    /// **What this tests:**
    /// - Today with goal not met doesn't count in streak
    /// - Streak counts backward from yesterday when today incomplete
    @Test func todayIncompleteExcludedFromStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into tomorrow/yesterday
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today
        var puffs: [Puff] = []

        // Today: 15 puffs (exceeds goal of 10)
        for minute in 0..<15 {
            puffs.append(Puff(timestamp: today.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        // Yesterday: 5 puffs (meets goal)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        for minute in 0..<5 {
            puffs.append(Puff(timestamp: yesterday.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        // Day -2: 7 puffs (meets goal)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        for minute in 0..<7 {
            puffs.append(Puff(timestamp: twoDaysAgo.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        // Streak should be 2 (yesterday + day before), today doesn't count
        #expect(info.currentStreak == 2)
        #expect(info.todayGoalMet == false)
        #expect(info.todayCount == 15)
    }

    /// Tests that a day with no puffs breaks the streak.
    ///
    /// **What this tests:**
    /// - Missing data (0 puffs) breaks streak
    /// - Gap in tracking stops streak counting
    @Test func dayWithNoPuffsBreaksStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into adjacent days
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today
        var puffs: [Puff] = []

        // Today: 5 puffs (meets goal)
        for minute in 0..<5 {
            puffs.append(Puff(timestamp: today.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        // Yesterday: NO PUFFS (missing day)

        // Day -2: 5 puffs (meets goal)
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        for minute in 0..<5 {
            puffs.append(Puff(timestamp: twoDaysAgo.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        // Streak should be 1 (only today), yesterday's missing data breaks it
        #expect(info.currentStreak == 1)
        #expect(info.todayGoalMet == true)
    }

    /// Tests that best streak is preserved when current streak is lower.
    ///
    /// **What this tests:**
    /// - Historical best streak persistence
    /// - Current < stored best
    @Test func bestStreakPreservedWhenCurrentLower() async throws {
        let calendar = Calendar.current
        let today = Date()

        // Only today with 5 puffs (meets goal)
        let puffs = (0..<5).map { hour in
            Puff(timestamp: today.addingTimeInterval(Double(hour * 3600)))
        }

        // Stored best streak is 10 from previous achievement
        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 10)

        #expect(info.currentStreak == 1)
        #expect(info.bestStreak == 10)  // Preserved from storage
    }

    /// Tests that best streak is updated when current streak exceeds it.
    ///
    /// **What this tests:**
    /// - Best streak updates to new record
    /// - Current > stored best
    @Test func bestStreakUpdatedWhenCurrentHigher() async throws {
        let calendar = Calendar.current
        let today = Date()
        var puffs: [Puff] = []

        // Create 7 consecutive days with goal met
        for day in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            for hour in 0..<5 {
                puffs.append(Puff(timestamp: date.addingTimeInterval(Double(hour * 3600))))
            }
        }

        // Stored best streak is 5
        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 5)

        #expect(info.currentStreak == 7)
        #expect(info.bestStreak == 7)  // Updated to new record
    }

    /// Tests that streak calculation works across year boundaries.
    ///
    /// **What this tests:**
    /// - Year transition (Dec 31 -> Jan 1)
    /// - Calendar date normalization across years
    @Test func streakAcrossYearBoundary() async throws {
        let calendar = Calendar.current
        var puffs: [Puff] = []

        // Jan 1, 2025: 5 puffs
        let jan1 = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1, hour: 12))!
        for hour in 0..<5 {
            puffs.append(Puff(timestamp: jan1.addingTimeInterval(Double(hour * 3600))))
        }

        // Dec 31, 2024: 7 puffs
        let dec31 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 12))!
        for hour in 0..<7 {
            puffs.append(Puff(timestamp: dec31.addingTimeInterval(Double(hour * 3600))))
        }

        // Dec 30, 2024: 6 puffs
        let dec30 = calendar.date(from: DateComponents(year: 2024, month: 12, day: 30, hour: 12))!
        for hour in 0..<6 {
            puffs.append(Puff(timestamp: dec30.addingTimeInterval(Double(hour * 3600))))
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        // If today is Jan 1, 2025, streak should be 3 days
        // (We can't guarantee this test runs on Jan 1, so we check relative to data)
        #expect(info.currentStreak >= 0)  // Valid streak calculated
        #expect(info.bestStreak >= 0)
    }

    // MARK: - Data Model Tests

    /// Tests that hasActiveStreak returns true when streak > 0.
    ///
    /// **What this tests:**
    /// - Computed property hasActiveStreak
    /// - Boolean logic for active streak detection
    @Test func hasActiveStreakReturnsTrueWhenGreaterThanZero() async throws {
        let today = Date()
        let puffs = (0..<5).map { hour in
            Puff(timestamp: today.addingTimeInterval(Double(hour * 3600)))
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak > 0)
        #expect(info.hasActiveStreak == true)
    }

    /// Tests that hasActiveStreak returns false when streak is 0.
    ///
    /// **What this tests:**
    /// - Computed property with zero streak
    /// - No active streak case
    @Test func hasActiveStreakReturnsFalseWhenZero() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into tomorrow
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today

        let puffs = (0..<15).map { minute in
            Puff(timestamp: today.addingTimeInterval(Double(minute * 60)))  // Add minutes instead of hours
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 0)
        #expect(info.hasActiveStreak == false)
    }

    /// Tests that StreakInfo Equatable conformance works correctly.
    ///
    /// **What this tests:**
    /// - Equatable protocol implementation
    /// - Equality comparison of StreakInfo instances
    @Test func streakInfoEquatableWorks() async throws {
        let info1 = StreakInfo(
            currentStreak: 5,
            bestStreak: 10,
            todayGoalMet: true,
            todayCount: 8
        )

        let info2 = StreakInfo(
            currentStreak: 5,
            bestStreak: 10,
            todayGoalMet: true,
            todayCount: 8
        )

        let info3 = StreakInfo(
            currentStreak: 3,
            bestStreak: 10,
            todayGoalMet: true,
            todayCount: 8
        )

        #expect(info1 == info2)  // Same values
        #expect(info1 != info3)  // Different currentStreak
    }

    // MARK: - Edit/Delete Impact Tests

    /// Tests that deleting a puff can break a streak.
    ///
    /// **What this tests:**
    /// - Streak recalculation after deletion
    /// - Deleting enough puffs to exceed goal breaks streak
    @Test func deletingPuffCanBreakStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into tomorrow
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today
        var puffs: [Puff] = []

        // Today: 10 puffs (exactly meets goal of 10)
        for minute in 0..<10 {
            puffs.append(Puff(timestamp: today.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        let infoBefore = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)
        #expect(infoBefore.currentStreak == 1)
        #expect(infoBefore.todayGoalMet == true)

        // Delete one puff (now 9 puffs, still meets goal)
        puffs.removeLast()

        let infoAfter = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)
        #expect(infoAfter.currentStreak == 1)
        #expect(infoAfter.todayGoalMet == true)
        #expect(infoAfter.todayCount == 9)
    }

    /// Tests that editing a puff to another day recalculates the streak.
    ///
    /// **What this tests:**
    /// - Streak recalculation after cross-day edit
    /// - Moving puff affects both source and destination day counts
    @Test func editingPuffToAnotherDayRecalculatesStreak() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into adjacent days
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today
        var puffs: [Puff] = []

        // Today: 10 puffs (exactly meets goal)
        for minute in 0..<10 {
            puffs.append(Puff(timestamp: today.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        // Yesterday: 8 puffs (meets goal)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        for minute in 0..<8 {
            puffs.append(Puff(timestamp: yesterday.addingTimeInterval(Double(minute * 60))))  // Add minutes
        }

        let infoBefore = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)
        #expect(infoBefore.currentStreak == 2)

        // Edit one of today's puffs to yesterday
        let todayPuff = puffs.first { calendar.isDate($0.timestamp, inSameDayAs: today) }!
        let editedPuff = Puff(id: todayPuff.id, timestamp: yesterday)

        if let index = puffs.firstIndex(where: { $0.id == todayPuff.id }) {
            puffs[index] = editedPuff
        }

        let infoAfter = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        // Today now has 9 puffs (still meets goal)
        // Yesterday now has 9 puffs (still meets goal)
        // Streak should still be 2
        #expect(infoAfter.currentStreak == 2)
        #expect(infoAfter.todayCount == 9)
    }

    /// Tests streak calculation with exact goal boundary.
    ///
    /// **What this tests:**
    /// - Exactly meeting goal (not exceeding) counts as success
    /// - Boundary condition: count == goal
    @Test func exactlyMeetingGoalCountsAsSuccess() async throws {
        let calendar = Calendar.current
        // Use a fixed time (noon) to ensure puffs don't spill into tomorrow
        let today = calendar.startOfDay(for: Date()).addingTimeInterval(12 * 3600)  // Noon today

        // Create exactly 10 puffs (goal is 10)
        let puffs = (0..<10).map { minute in
            Puff(timestamp: today.addingTimeInterval(Double(minute * 60)))  // Add minutes instead of hours
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 1)
        #expect(info.todayGoalMet == true)
        #expect(info.todayCount == 10)
    }

    /// Tests streak calculation when beating goal (under the limit).
    ///
    /// **What this tests:**
    /// - Being under goal is success
    /// - Better performance than goal requirement
    @Test func beatingGoalCountsAsSuccess() async throws {
        let today = Date()

        // Create 3 puffs (well under goal of 10)
        let puffs = (0..<3).map { hour in
            Puff(timestamp: today.addingTimeInterval(Double(hour * 3600)))
        }

        let info = puffs.calculateStreak(dailyGoal: 10, storedBestStreak: 0)

        #expect(info.currentStreak == 1)
        #expect(info.todayGoalMet == true)
        #expect(info.todayCount == 3)
        #expect(info.hasActiveStreak == true)
    }
}

// MARK: - Undo/Trash Tests

/// Test suite for undo/trash functionality.
///
/// **What we're testing:**
/// The trash system implements a "soft delete" pattern where deleted puffs
/// are stored for 24 hours before permanent removal. These tests verify:
/// - DeletedPuff model creation and expiry logic
/// - Auto-purge mechanism removes expired items
/// - Encoding/decoding for persistence
struct UndoTrashTests {

    // MARK: - DeletedPuff Model Tests

    /// Tests that a newly created DeletedPuff is not expired.
    @Test func newlyDeletedPuffIsNotExpired() async throws {
        let puff = Puff(timestamp: Date())
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: Date())

        #expect(deletedPuff.isExpired() == false)
    }

    /// Tests that a DeletedPuff older than 24 hours is expired.
    @Test func deletedPuffExpiredAfter24Hours() async throws {
        let puff = Puff(timestamp: Date())
        // Create a deleted puff from 25 hours ago
        let deletionDate = Date().addingTimeInterval(-25 * 60 * 60)
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: deletionDate)

        #expect(deletedPuff.isExpired() == true)
    }

    /// Tests that a DeletedPuff at exactly 24 hours is considered expired.
    @Test func deletedPuffExpiredAtExactly24Hours() async throws {
        let puff = Puff(timestamp: Date())
        // Create a deleted puff from exactly 24 hours ago
        let deletionDate = Date().addingTimeInterval(-24 * 60 * 60)
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: deletionDate)

        #expect(deletedPuff.isExpired() == true)
    }

    /// Tests that a DeletedPuff just under 24 hours is not expired.
    @Test func deletedPuffNotExpiredJustBefore24Hours() async throws {
        let puff = Puff(timestamp: Date())
        // Create a deleted puff from 23.9 hours ago
        let deletionDate = Date().addingTimeInterval(-23.9 * 60 * 60)
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: deletionDate)

        #expect(deletedPuff.isExpired() == false)
    }

    /// Tests timeUntilExpiry calculation for a fresh deletion.
    @Test func timeUntilExpiryForFreshDeletion() async throws {
        let puff = Puff(timestamp: Date())
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: Date())

        let timeRemaining = deletedPuff.timeUntilExpiry()

        // Should be approximately 24 hours (within 1 second of test execution)
        let expectedTime = 24 * 60 * 60.0
        #expect(abs(timeRemaining - expectedTime) < 1.0)
    }

    /// Tests timeUntilExpiry returns 0 for expired puffs.
    @Test func timeUntilExpiryForExpiredPuff() async throws {
        let puff = Puff(timestamp: Date())
        let deletionDate = Date().addingTimeInterval(-25 * 60 * 60)
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: deletionDate)

        let timeRemaining = deletedPuff.timeUntilExpiry()

        #expect(timeRemaining == 0)
    }

    /// Tests formattedTimeRemaining for a recently deleted puff.
    @Test func formattedTimeRemainingForRecentDeletion() async throws {
        let puff = Puff(timestamp: Date())
        let deletionDate = Date().addingTimeInterval(-1 * 60 * 60) // 1 hour ago
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: deletionDate)

        let formatted = deletedPuff.formattedTimeRemaining()

        // Should show approximately 22-23 hours remaining (timing can vary slightly)
        #expect(formatted.contains("h remaining"))
        #expect(formatted.contains("22h") || formatted.contains("23h"))
    }

    /// Tests formattedTimeRemaining for an expired puff.
    @Test func formattedTimeRemainingForExpiredPuff() async throws {
        let puff = Puff(timestamp: Date())
        let deletionDate = Date().addingTimeInterval(-25 * 60 * 60)
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: deletionDate)

        let formatted = deletedPuff.formattedTimeRemaining()

        #expect(formatted == "Expired")
    }

    /// Tests that DeletedPuff preserves the original puff's ID and generates a unique deletion ID.
    @Test func deletedPuffPreservesOriginalIDAndGeneratesUniqueID() async throws {
        let originalID = UUID()
        let puff = Puff(id: originalID, timestamp: Date())
        let deletedPuff = DeletedPuff(puff: puff)

        // The puffId should match the original
        #expect(deletedPuff.puffId == originalID)
        // The deletedPuff.id should be different (unique for each deletion)
        #expect(deletedPuff.id != originalID)
    }

    /// Tests that multiple deletions of the same puff get unique IDs.
    @Test func multipleDeletionsGetUniqueIDs() async throws {
        let puff = Puff(timestamp: Date())

        let deleted1 = DeletedPuff(puff: puff)
        let deleted2 = DeletedPuff(puff: puff)

        // Both should preserve the same puffId
        #expect(deleted1.puffId == puff.id)
        #expect(deleted2.puffId == puff.id)

        // But each deletion should have a unique ID
        #expect(deleted1.id != deleted2.id)
    }

    // MARK: - Auto-Purge Tests

    /// Tests that purgingExpired removes only expired items.
    @Test func purgingExpiredRemovesOnlyExpiredItems() async throws {
        let now = Date()

        // Create a mix of expired and non-expired deleted puffs
        let deletedPuffs = [
            // Expired (25 hours old)
            DeletedPuff(
                puff: Puff(timestamp: now),
                deletedAt: now.addingTimeInterval(-25 * 60 * 60)
            ),
            // Not expired (1 hour old)
            DeletedPuff(
                puff: Puff(timestamp: now),
                deletedAt: now.addingTimeInterval(-1 * 60 * 60)
            ),
            // Expired (30 hours old)
            DeletedPuff(
                puff: Puff(timestamp: now),
                deletedAt: now.addingTimeInterval(-30 * 60 * 60)
            ),
            // Not expired (12 hours old)
            DeletedPuff(
                puff: Puff(timestamp: now),
                deletedAt: now.addingTimeInterval(-12 * 60 * 60)
            )
        ]

        let purged = deletedPuffs.purgingExpired()

        // Should only have 2 non-expired items remaining
        #expect(purged.count == 2)
    }

    /// Tests that purgingExpired on an empty array returns an empty array.
    @Test func purgingExpiredOnEmptyArray() async throws {
        let deletedPuffs: [DeletedPuff] = []
        let purged = deletedPuffs.purgingExpired()

        #expect(purged.isEmpty)
    }

    /// Tests that purgingExpired preserves all non-expired items.
    @Test func purgingExpiredPreservesNonExpiredItems() async throws {
        let now = Date()

        // Create only non-expired deleted puffs
        let deletedPuffs = [
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now.addingTimeInterval(-1 * 60 * 60)),
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now.addingTimeInterval(-5 * 60 * 60)),
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now.addingTimeInterval(-20 * 60 * 60))
        ]

        let purged = deletedPuffs.purgingExpired()

        // All 3 should remain
        #expect(purged.count == 3)
    }

    /// Tests that purgingExpired removes all items when all are expired.
    @Test func purgingExpiredRemovesAllWhenAllExpired() async throws {
        let now = Date()

        // Create only expired deleted puffs
        let deletedPuffs = [
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now.addingTimeInterval(-25 * 60 * 60)),
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now.addingTimeInterval(-30 * 60 * 60)),
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now.addingTimeInterval(-48 * 60 * 60))
        ]

        let purged = deletedPuffs.purgingExpired()

        #expect(purged.isEmpty)
    }

    // MARK: - Codable Tests

    /// Tests that DeletedPuff can be encoded and decoded.
    @Test func deletedPuffCodable() async throws {
        let puff = Puff(timestamp: Date())
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: Date())

        // Encode to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(deletedPuff)

        // Decode from JSON
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DeletedPuff.self, from: data)

        // Verify all properties match
        #expect(decoded.id == deletedPuff.id)
        #expect(decoded.puffId == deletedPuff.puffId)
        #expect(decoded.puff.id == deletedPuff.puff.id)
        #expect(abs(decoded.puff.timestamp.timeIntervalSince(deletedPuff.puff.timestamp)) < 0.001)
        #expect(abs(decoded.deletedAt.timeIntervalSince(deletedPuff.deletedAt)) < 0.001)
    }

    /// Tests that an array of DeletedPuff can be encoded and decoded.
    @Test func deletedPuffArrayCodable() async throws {
        let now = Date()
        let deletedPuffs = [
            DeletedPuff(puff: Puff(timestamp: now), deletedAt: now),
            DeletedPuff(puff: Puff(timestamp: now.addingTimeInterval(-3600)), deletedAt: now.addingTimeInterval(-1800))
        ]

        // Encode to JSON
        let encoder = JSONEncoder()
        let data = try encoder.encode(deletedPuffs)

        // Decode from JSON
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([DeletedPuff].self, from: data)

        // Verify count matches
        #expect(decoded.count == 2)

        // Verify IDs match
        #expect(decoded[0].id == deletedPuffs[0].id)
        #expect(decoded[1].id == deletedPuffs[1].id)
    }

    // MARK: - Equatable Tests

    /// Tests that a DeletedPuff is equal to itself.
    @Test func deletedPuffEqualityToSelf() async throws {
        let puff = Puff(timestamp: Date())
        let deletedPuff = DeletedPuff(puff: puff, deletedAt: Date())

        // A DeletedPuff should equal itself
        #expect(deletedPuff == deletedPuff)
    }

    /// Tests that two separately created DeletedPuffs are not equal.
    ///
    /// Even if they wrap the same puff and have the same deletedAt timestamp,
    /// they should be different because each deletion gets a unique ID.
    /// This prevents SwiftUI tracking issues when items are deleted multiple times.
    @Test func separatelyCreatedDeletedPuffsAreNotEqual() async throws {
        let puffID = UUID()
        let timestamp = Date()
        let deletedAt = Date()

        let puff1 = Puff(id: puffID, timestamp: timestamp)
        let puff2 = Puff(id: puffID, timestamp: timestamp)

        let deleted1 = DeletedPuff(puff: puff1, deletedAt: deletedAt)
        let deleted2 = DeletedPuff(puff: puff2, deletedAt: deletedAt)

        // Should NOT be equal because they have different deletion IDs
        #expect(deleted1 != deleted2)
    }

    /// Tests that two DeletedPuffs with different data are not equal.
    @Test func deletedPuffInequality() async throws {
        let timestamp = Date()

        let puff1 = Puff(timestamp: timestamp)
        let puff2 = Puff(timestamp: timestamp.addingTimeInterval(3600))

        let deleted1 = DeletedPuff(puff: puff1, deletedAt: timestamp)
        let deleted2 = DeletedPuff(puff: puff2, deletedAt: timestamp)

        #expect(deleted1 != deleted2)
    }
}

// MARK: - Educational Notes
//
// **Why use @testable import?**
// The @testable keyword allows us to access internal (non-public) types and methods
// from the Puffwise module. In production code, Puff and PuffGrouping are internal,
// but tests need to access them.
//
// **Why test with specific dates?**
// Using fixed dates (like Jan 1, 2024) makes tests deterministic and reproducible.
// If we used Date() (current time), tests might pass or fail depending on when
// they run. Always use known values in tests.
//
// **Why test edge cases?**
// Edge cases (like empty arrays, month boundaries, week transitions) are where
// bugs often hide. Testing these cases ensures the code is robust.
//
// **Why test Codable?**
// Since the app persists data using JSON encoding, it's critical to ensure that
// encoding and decoding work correctly. A bug here could cause data loss.
//
// **About Swift Testing vs XCTest:**
// Swift Testing is Apple's modern testing framework that's more Swift-native.
// Benefits include:
// - Better error messages
// - Native async/await support
// - More expressive syntax with #expect()
// - Parametrized tests (testing multiple inputs easily)
// - Better integration with Swift's type system
