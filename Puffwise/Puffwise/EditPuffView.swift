//
//  EditPuffView.swift
//  Puffwise
//
//  View for editing a puff's timestamp.
//  Presents a modal sheet with a DatePicker allowing users to correct
//  the date and time of a logged puff.
//

import SwiftUI

/// A view that allows editing the timestamp of an existing puff.
///
/// This view is presented as a modal sheet when the user taps a puff in HistoryView.
/// It displays a DatePicker for selecting both the date and time, along with
/// Save and Cancel buttons in the navigation toolbar.
///
/// **SwiftUI Concepts:**
/// - `@Environment(\.dismiss)`: Access to the dismiss action from the environment.
///   This is how modal sheets and navigation destinations dismiss themselves.
/// - `@State`: Holds the temporary edited timestamp while the user makes changes.
///   Only applied to the actual puff when the user taps Save.
/// - DatePicker: A built-in SwiftUI control for selecting dates and times.
///   Automatically adapts its UI based on the device and context.
///
/// **Usage Pattern:**
/// ```swift
/// .sheet(item: $puffToEdit) { puff in
///     EditPuffView(originalPuff: puff) { editedPuff in
///         // Handle the save
///     }
/// }
/// ```
struct EditPuffView: View {
    // Environment value for dismissing this sheet
    // When you call dismiss(), SwiftUI handles the sheet dismissal animation
    @Environment(\.dismiss) var dismiss

    // State variable holding the timestamp being edited
    // This starts as a copy of the original timestamp, then changes as the user
    // adjusts the DatePicker. It's only applied when the user taps Save.
    @State private var editedTimestamp: Date

    // The original puff being edited (immutable)
    // We keep this to preserve the puff's ID when creating the edited version
    let originalPuff: Puff

    // Callback invoked when the user taps Save
    // The parent view (HistoryView) provides this closure to handle the update
    let onSave: (Puff) -> Void

    // Custom initializer to set up the initial edited timestamp
    // We need this because @State properties need initial values, and we want
    // the DatePicker to start with the puff's current timestamp
    init(originalPuff: Puff, onSave: @escaping (Puff) -> Void) {
        self.originalPuff = originalPuff
        self.onSave = onSave
        // Initialize @State with the original timestamp
        // The underscore (_) syntax accesses the State property wrapper itself,
        // allowing us to set the wrapped value during initialization
        _editedTimestamp = State(initialValue: originalPuff.timestamp)
    }

    var body: some View {
        // NavigationStack provides the navigation bar for toolbar items
        NavigationStack {
            // Form provides the standard grouped-list appearance for settings-style UIs
            // It automatically adds proper spacing, backgrounds, and insets
            Form {
                Section {
                    // DatePicker allows selection of both date and time
                    // The label "Timestamp" appears next to the picker
                    // The $ prefix creates a binding, allowing DatePicker to both
                    // read and write the editedTimestamp value
                    DatePicker(
                        "Timestamp",
                        selection: $editedTimestamp,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    // displayedComponents controls which parts of the date/time the user can edit
                    // [.date, .hourAndMinute] shows both the calendar and time picker
                } header: {
                    Text("Edit Puff Timestamp")
                } footer: {
                    Text("Adjust the date and time when this puff was logged.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Puff")
            .navigationBarTitleDisplayMode(.inline)
            // Toolbar adds buttons to the navigation bar
            .toolbar {
                // Cancel button on the leading (left) side
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // Dismiss without calling onSave
                        // This discards any changes the user made
                        dismiss()
                    }
                }

                // Save button on the trailing (right) side
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Create a new Puff with the same ID but updated timestamp
                        // This preserves the puff's identity while changing its data
                        // (following the immutable pattern for the Puff model)
                        let editedPuff = Puff(
                            id: originalPuff.id,
                            timestamp: editedTimestamp
                        )

                        // Call the save handler provided by the parent view
                        onSave(editedPuff)

                        // Dismiss the sheet
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
// SwiftUI preview for development and design iteration
#Preview {
    // Create a sample puff for preview
    let samplePuff = Puff(
        timestamp: Date().addingTimeInterval(-3600) // 1 hour ago
    )

    // Wrap in a sheet presentation to simulate how it appears in the app
    // The .constant binding means the preview won't actually call the save handler
    return EditPuffView(originalPuff: samplePuff) { editedPuff in
        print("Preview: Saved puff with timestamp \(editedPuff.timestamp)")
    }
}
