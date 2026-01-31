//
//  GoalSettingsView.swift
//  Puffwise
//
//  Settings view for configuring the daily puff goal.
//

import SwiftUI

struct GoalSettingsView: View {
    // @Binding allows this view to access and modify puff data owned by the parent view.
    // This enables the export functionality to access the puff array for CSV generation.
    // Unlike @State which is owned by this view, @Binding creates a two-way connection
    // to state owned elsewhere (ContentView in this case).
    @Binding var puffs: [Puff]

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

    // State for error handling during CSV export.
    // @State creates view-local state that SwiftUI manages and persists across view updates.
    // When this state changes, SwiftUI re-renders the view to show/hide the alert.
    @State private var showExportError = false
    @State private var exportErrorMessage = ""

    // State to track the export file URL. Using Optional allows us to handle file creation
    // errors gracefully - if the URL is nil, we know the export failed.
    @State private var exportFileURL: URL?

    /// Prepares the CSV export file and returns the URL if successful.
    ///
    /// This method generates the CSV content, writes it to a temporary file, and returns
    /// the file URL for the ShareLink. If any step fails, it sets the error state and
    /// returns nil.
    ///
    /// - Returns: The URL of the temporary CSV file, or nil if export failed
    private func prepareExportFile() -> URL? {
        let csvContent = puffs.exportToCSV(dailyGoal: dailyPuffGoal)
        let filename = [Puff].exportFilename()
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        do {
            // Write CSV content to temporary file with UTF-8 encoding.
            // atomically: true ensures the file is fully written before replacing any existing file,
            // preventing corruption if the write is interrupted.
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            // Capture the error details for the alert.
            // Common errors: disk full, permission denied, invalid path
            exportErrorMessage = "Could not create export file: \(error.localizedDescription)"
            showExportError = true
            return nil
        }
    }

    // State to control the share sheet presentation.
    // When true, the ShareLink sheet will be presented.
    @State private var showShareSheet = false

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

                // Data export section
                // Using a Button with manual file preparation allows proper error handling.
                // When the button is tapped, we first try to create the CSV file, then present
                // the share sheet only if successful. If the file creation fails, we show an error alert.
                Section {
                    Button {
                        // Prepare the export file with error handling
                        if let url = prepareExportFile() {
                            exportFileURL = url
                            showShareSheet = true
                        }
                        // If prepareExportFile() returns nil, it sets showExportError = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    // Disable when there's no data to export
                    .disabled(puffs.isEmpty)
                } header: {
                    Text("Data")
                } footer: {
                    Text("Export your puff history as a CSV file for backup or analysis in spreadsheet apps.")
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
            // Present the share sheet when we have a valid file URL.
            // The sheet(isPresented:) modifier presents a modal sheet when the binding is true.
            // We use ShareLink inside the sheet since it needs a concrete (non-optional) URL.
            .sheet(isPresented: $showShareSheet) {
                // Clean up the temporary file when the share sheet is dismissed.
                // iOS eventually cleans up temp files, but explicit cleanup is good practice.
                if let url = exportFileURL {
                    try? FileManager.default.removeItem(at: url)
                }
                exportFileURL = nil
            } content: {
                if let url = exportFileURL {
                    // ShareLink presents the system share sheet with all standard iOS
                    // sharing destinations (Files, AirDrop, Mail, etc.).
                    ShareLink(
                        item: url,
                        preview: SharePreview(
                            "Puffwise Export",
                            image: Image(systemName: "chart.bar.doc.horizontal")
                        )
                    )
                    // Present as a minimal sheet for cleaner UX
                    .presentationDetents([.medium])
                }
            }
            // Alert modifier presents an error dialog when showExportError is true.
            // This is the standard SwiftUI pattern for displaying errors to users.
            .alert("Export Failed", isPresented: $showExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(exportErrorMessage)
            }
        }
    }
}

// SwiftUI previews let us see the view in Xcode's canvas without running the app.
// Previews update in real-time as you edit the code.
// Using .constant() creates a read-only binding for preview purposes.
#Preview {
    GoalSettingsView(puffs: .constant([
        Puff(timestamp: Date()),
        Puff(timestamp: Date().addingTimeInterval(-3600))
    ]))
}
