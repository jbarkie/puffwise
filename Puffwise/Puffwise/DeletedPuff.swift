//
//  DeletedPuff.swift
//  Puffwise
//
//  Model for tracking deleted puffs that can be restored within 24 hours.
//  This provides an undo mechanism for accidental deletions.
//

import Foundation

/// DeletedPuff represents a puff that has been moved to the trash.
///
/// When a user deletes a puff, it's not immediately removed from the system.
/// Instead, it's wrapped in a DeletedPuff with a deletion timestamp and stored
/// separately. This allows for a 24-hour recovery period before permanent deletion.
///
/// **Design Pattern:**
/// This follows the "soft delete" pattern common in many applications, where
/// deletions are initially reversible. After the recovery period expires, the
/// auto-purge mechanism permanently removes the item.
///
/// **SwiftUI Integration:**
/// - Codable: Enables persistence to UserDefaults via JSON encoding
/// - Identifiable: Allows SwiftUI to track items in Lists and ForEach loops
/// - Equatable: Enables change detection and array operations
struct DeletedPuff: Codable, Identifiable, Equatable {
    /// Unique identifier for this deleted puff entry.
    /// Uses the original puff's ID to maintain consistency during restore.
    let id: UUID

    /// The original puff that was deleted.
    /// Stored so it can be fully restored with all original data intact.
    let puff: Puff

    /// Timestamp when this puff was deleted.
    /// Used to calculate expiry (24 hours from deletion) and display time remaining.
    let deletedAt: Date

    /// Creates a new deleted puff entry.
    ///
    /// - Parameters:
    ///   - puff: The original puff being deleted
    ///   - deletedAt: The deletion timestamp (defaults to current time)
    init(puff: Puff, deletedAt: Date = Date()) {
        self.id = puff.id // Use the puff's ID for consistency
        self.puff = puff
        self.deletedAt = deletedAt
    }

    /// Calculates whether this deleted puff has expired (older than 24 hours).
    ///
    /// Expired puffs should be permanently removed by the auto-purge mechanism.
    ///
    /// **Implementation Note:**
    /// Uses 24 hours (86400 seconds) as the recovery window. This gives users
    /// a full day to realize they made a mistake and restore the puff.
    ///
    /// - Returns: True if the puff was deleted more than 24 hours ago
    func isExpired() -> Bool {
        let expiryInterval: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
        let expiryDate = deletedAt.addingTimeInterval(expiryInterval)
        return Date() >= expiryDate
    }

    /// Calculates the time remaining until permanent deletion.
    ///
    /// This can be used in the UI to show users how much time they have
    /// to restore a deleted puff.
    ///
    /// - Returns: Time interval remaining until expiry, or 0 if already expired
    func timeUntilExpiry() -> TimeInterval {
        let expiryInterval: TimeInterval = 24 * 60 * 60 // 24 hours
        let expiryDate = deletedAt.addingTimeInterval(expiryInterval)
        let remaining = expiryDate.timeIntervalSince(Date())
        return max(0, remaining) // Never return negative values
    }

    /// Formats the time remaining as a human-readable string.
    ///
    /// Returns strings like "23h remaining", "5h remaining", or "Expires soon"
    /// for items with less than 1 hour remaining.
    ///
    /// - Returns: A formatted string showing time until permanent deletion
    func formattedTimeRemaining() -> String {
        let remaining = timeUntilExpiry()

        if remaining <= 0 {
            return "Expired"
        }

        let hours = Int(remaining / 3600)

        if hours < 1 {
            let minutes = Int(remaining / 60)
            if minutes < 1 {
                return "Expires soon"
            }
            return "\(minutes)m remaining"
        }

        return "\(hours)h remaining"
    }
}

// MARK: - Array Extension for Trash Management

extension Array where Element == DeletedPuff {
    /// Removes all expired deleted puffs from the array.
    ///
    /// This auto-purge mechanism should be called:
    /// - On app launch (to clean up old items)
    /// - Before adding new deleted items (to keep storage clean)
    /// - Periodically when viewing the trash
    ///
    /// **Performance Note:**
    /// This creates a new filtered array rather than removing items in-place.
    /// For typical usage (hundreds of deleted puffs max), this is efficient.
    ///
    /// - Returns: A new array containing only non-expired deleted puffs
    func purgingExpired() -> [DeletedPuff] {
        return self.filter { !$0.isExpired() }
    }
}
