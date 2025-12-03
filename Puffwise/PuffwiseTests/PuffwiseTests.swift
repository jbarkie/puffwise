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
