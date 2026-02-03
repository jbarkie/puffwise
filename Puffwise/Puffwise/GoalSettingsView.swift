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

    // Reminder settings stored in UserDefaults via @AppStorage.
    // These persist across app launches and are used to restore notification scheduling.
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 20
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    // @Environment(\.dismiss) provides access to the dismiss action from the SwiftUI environment.
    // This is the modern way to dismiss sheets, popovers, and other presented views.
    // When called, it dismisses the current view presentation.
    // This replaces the older @Environment(\.presentationMode) pattern.
    @Environment(\.dismiss) private var dismiss

    // State for CSV export error handling.
    // When file writing fails, we show an alert instead of silently failing.
    @State private var showingExportError = false
    @State private var exportErrorMessage = ""

    // State for notification permission denied alert.
    // Shown when user tries to enable reminders but has denied notification permissions.
    @State private var showingPermissionDeniedAlert = false

    // Cached URL for the export file.
    // We prepare the file before ShareLink is tapped to ensure it's ready.
    // Note: Files in temporaryDirectory are automatically cleaned up by iOS
    // when the system needs space or during device restarts.
    @State private var cachedExportURL: URL?

    /// Computed binding for the reminder time DatePicker.
    ///
    /// **Why a Computed Binding?**
    /// DatePicker requires a Date binding, but we store hour and minute separately
    /// in @AppStorage for simplicity and type safety. This computed binding:
    /// - Creates a Date from stored hour/minute for the picker to display
    /// - Extracts hour/minute from the Date when user changes the time
    /// - Reschedules the notification whenever the time changes
    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                // Create a Date from the stored hour and minute components
                var components = DateComponents()
                components.hour = reminderHour
                components.minute = reminderMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                // Extract hour and minute from the new Date
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                reminderHour = components.hour ?? 20
                reminderMinute = components.minute ?? 0

                // Reschedule notification if reminders are enabled
                if reminderEnabled {
                    Task {
                        await NotificationManager.shared.scheduleDailyReminder(
                            hour: reminderHour,
                            minute: reminderMinute
                        )
                    }
                }
            }
        )
    }

    /// Prepares the CSV export file for sharing.
    ///
    /// This function generates the CSV content and writes it to a temporary file.
    /// If writing fails, it sets the error state to show an alert to the user.
    private func prepareExportFile() {
        let csvContent = puffs.exportToCSV(dailyGoal: dailyPuffGoal)
        let filename = [Puff].exportFilename()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)

        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            cachedExportURL = tempURL
        } catch {
            cachedExportURL = nil
            exportErrorMessage = error.localizedDescription
            showingExportError = true
        }
    }

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

                // Reminders section
                // Toggle is a SwiftUI control for boolean on/off states.
                // When combined with @AppStorage, changes persist automatically.
                Section {
                    Toggle("Daily Reminder", isOn: Binding(
                        get: { reminderEnabled },
                        set: { newValue in
                            if newValue {
                                // User wants to enable reminders - request permission first
                                Task {
                                    let granted = await NotificationManager.shared.requestPermission()
                                    // Schedule notification before updating UI (if granted)
                                    if granted {
                                        await NotificationManager.shared.scheduleDailyReminder(
                                            hour: reminderHour,
                                            minute: reminderMinute
                                        )
                                    }
                                    // Update UI state on main actor
                                    await MainActor.run {
                                        if granted {
                                            reminderEnabled = true
                                        } else {
                                            // Permission denied - reset toggle and show alert
                                            reminderEnabled = false
                                            showingPermissionDeniedAlert = true
                                        }
                                    }
                                }
                            } else {
                                // User wants to disable reminders
                                reminderEnabled = false
                                NotificationManager.shared.cancelDailyReminder()
                            }
                        }
                    ))

                    // Only show time picker when reminders are enabled
                    // DatePicker with displayedComponents: .hourAndMinute shows only time selection
                    if reminderEnabled {
                        DatePicker(
                            "Reminder Time",
                            selection: reminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Get a daily reminder to log your puffs and check your progress.")
                }

                // Data export section
                // ShareLink is a SwiftUI view (iOS 16+) that presents the system share sheet.
                // It's simpler than the older fileExporter modifier and integrates with
                // all standard iOS sharing destinations (Files, AirDrop, Mail, etc.).
                // Using a file URL (instead of raw String) preserves the .csv filename extension.
                Section {
                    // Only show ShareLink when we have a valid cached URL.
                    // If file preparation failed, cachedExportURL will be nil.
                    if let exportURL = cachedExportURL {
                        ShareLink(
                            item: exportURL,
                            preview: SharePreview(
                                "Puffwise Export",
                                image: Image(systemName: "chart.bar.doc.horizontal")
                            )
                        ) {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                        // Disable when there's no data to export
                        .disabled(puffs.isEmpty)
                    } else {
                        // Show disabled button if file preparation failed
                        Button {
                            prepareExportFile()
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                        .disabled(puffs.isEmpty)
                    }
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
            // Prepare the export file when the view appears or when puffs change.
            // .task runs an async operation when the view appears; using `id:` makes it
            // re-run whenever that value changes (similar to .onChange but with async support).
            .task(id: puffs.count) {
                prepareExportFile()
            }
            // Alert shown when CSV file creation fails
            .alert("Export Failed", isPresented: $showingExportError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Could not create export file: \(exportErrorMessage)")
            }
            // Alert shown when notification permission is denied.
            // Offers a button to open Settings where users can enable notifications.
            .alert("Notifications Disabled", isPresented: $showingPermissionDeniedAlert) {
                Button("Open Settings") {
                    // UIApplication.openSettingsURLString opens the app's Settings page
                    // where users can change notification permissions.
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive daily reminders.")
            }
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
// Using .constant() creates a read-only binding for preview purposes.
#Preview {
    GoalSettingsView(puffs: .constant([
        Puff(timestamp: Date()),
        Puff(timestamp: Date().addingTimeInterval(-3600))
    ]))
}
