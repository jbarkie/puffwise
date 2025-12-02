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
// **About Swift Testing vs XCTest:**
// Swift Testing is Apple's modern testing framework that's more Swift-native.
// Benefits include:
// - Better error messages
// - Native async/await support
// - More expressive syntax with #expect()
// - Parametrized tests (testing multiple inputs easily)
// - Better integration with Swift's type system
