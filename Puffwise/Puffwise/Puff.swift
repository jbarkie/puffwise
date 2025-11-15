import Foundation

// Puff represents a single logged puff with a timestamp.
// This struct is the core data model for tracking individual puffs over time.
struct Puff: Codable, Identifiable {
    // Identifiable requires an 'id' property so SwiftUI can track items in lists.
    // UUID (Universally Unique Identifier) ensures each puff has a unique ID.
    let id: UUID

    // Date stores the exact moment when this puff was logged.
    // We'll use this to filter puffs by day, week, month, etc.
    let timestamp: Date

    // Convenience initializer that creates a new puff with the current time.
    // If no timestamp is provided, it defaults to Date() (right now).
    init(id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.timestamp = timestamp
    }
}

// MARK: - About the Protocols
//
// Codable: This protocol (actually a type alias for Encodable & Decodable) allows Swift
// to automatically convert this struct to/from JSON or other formats. This is what enables
// us to store an array of Puff objects in UserDefaults using @AppStorage.
//
// Identifiable: This protocol requires an 'id' property. It's used by SwiftUI to efficiently
// track items in Lists and ForEach loops. Each item needs a stable, unique identifier so
// SwiftUI knows which items changed, moved, or were deleted.
