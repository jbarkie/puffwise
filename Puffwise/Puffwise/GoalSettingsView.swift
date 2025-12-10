//
//  GoalSettingsView.swift
//  Puffwise
//
//  Settings view for configuring the daily puff goal.
//

import SwiftUI

struct GoalSettingsView: View {
    // @AppStorage is a SwiftUI property wrapper that provides automatic persistence to UserDefaults.
    // Unlike @State, it automatically syncs with UserDefaults storage.
    // Benefits:
    // - Automatic persistence: Changes are saved immediately to disk
    // - Two-way binding: Changes in UserDefaults reflect in the UI automatically
    // - Type-safe: Supports Int, String, Bool, Double, URL, Data out of the box
    // - Simple syntax: More concise than manual UserDefaults.standard.set() calls
    //
    // The storage key "dailyPuffGoal" must match across all views that need to share this value.
    // Default value (10) is used when the key doesn't exist in UserDefaults (first launch).
    @AppStorage("dailyPuffGoal") private var dailyPuffGoal: Int = 10

    // @Environment(\.dismiss) provides access to the dismiss action from the SwiftUI environment.
    // This is the modern way to dismiss sheets, popovers, and other presented views.
    // When called, it dismisses the current view presentation.
    // This replaces the older @Environment(\.presentationMode) pattern.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // NavigationStack provides the navigation bar for our settings sheet.
        // Even though this is a modal sheet, we still need NavigationStack for the toolbar.
        NavigationStack {
            // Form is a container for grouping controls in a settings-style interface.
            // It automatically provides:
            // - Grouped, inset appearance on iOS
            // - Proper spacing between sections
            // - Standard iOS settings styling
            // - Accessibility support
            Form {
                Section {
                    // Stepper is a control for incrementing/decrementing numeric values.
                    // Advantages over TextField for numeric input:
                    // - Prevents invalid input (no need to parse/validate strings)
                    // - Enforces min/max bounds automatically (in: 1...100)
                    // - More accessible (clear +/- buttons for VoiceOver)
                    // - Better UX for small adjustments
                    //
                    // The $ prefix creates a binding to dailyPuffGoal, allowing Stepper
                    // to both read and write the value. Changes are automatically persisted
                    // via @AppStorage.
                    Stepper(value: $dailyPuffGoal, in: 1...100) {
                        HStack {
                            Text("Daily Puff Goal")
                                .font(.body)
                            Spacer()
                            // Display the current value in a secondary color
                            Text("\(dailyPuffGoal)")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    // Section header appears above the section in small caps
                    Text("Target")
                } footer: {
                    // Section footer appears below the section in smaller, secondary text
                    // Use footer for explanatory text or help content
                    Text("Set your target number of puffs per day. This helps you track your progress toward reducing usage.")
                }
            }
            // Navigation title appears in the navigation bar
            .navigationTitle("Goal Settings")
            // .inline makes the title smaller and appear on the same line as toolbar items
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ToolbarItem lets us add buttons and controls to the navigation bar
                // .topBarTrailing places the item in the top-right (leading would be top-left)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // Dismiss the sheet when Done is tapped
                        // This is the standard iOS pattern for modal settings sheets
                        dismiss()
                    }
                }
            }
        }
    }
}

// SwiftUI previews let us see the view in Xcode's canvas without running the app.
// Previews update in real-time as you edit the code.
#Preview {
    GoalSettingsView()
}
