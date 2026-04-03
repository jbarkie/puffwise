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
    // store: .shared writes to the App Group container so the widget can read the same value.
    @AppStorage("dailyPuffGoal", store: .shared) private var dailyPuffGoal: Int = 10

    // Reminder settings stored in UserDefaults via @AppStorage.
    // These persist across app launches and are used to restore notification scheduling.
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false
    @AppStorage("reminderHour") private var reminderHour: Int = 20
    @AppStorage("reminderMinute") private var reminderMinute: Int = 0

    // Reduction mode settings.
    // reductionPlanData holds a JSON-encoded ReductionPlan; it is created when the toggle
    // is enabled and decoded for status display while reduction mode is active.
    @AppStorage("reductionModeEnabled") private var reductionModeEnabled: Bool = false
    @AppStorage("reductionPlanData") private var reductionPlanData: Data = Data()
    @AppStorage("weeklyReductionPercent") private var weeklyReductionPercent: Int = 5
    @AppStorage("minimumFloor") private var minimumFloor: Int = 5

    // @Environment(\.dismiss) provides access to the dismiss action from the SwiftUI environment.
    // This is the modern way to dismiss sheets, popovers, and other presented views.
    // When called, it dismisses the current view presentation.
    // This replaces the older @Environment(\.presentationMode) pattern.
    @Environment(\.dismiss) private var dismiss

    // State for CSV export error handling.
    // When file writing fails, we show an alert instead of silently failing.
    @State private var showingExportError = false

    #if DEBUG
    // Number of weeks to shift the plan's startDate backwards when testing.
    // @AppStorage keeps the value alive across sheet dismissals within a session.
    @AppStorage("debugSimulateWeekOffset") private var debugWeekOffset: Int = 0
    #endif
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

    /// Decoded plan for status display; nil when mode is off or data is absent.
    private var currentReductionPlan: ReductionPlan? {
        guard reductionModeEnabled, !reductionPlanData.isEmpty else { return nil }
        return try? JSONDecoder().decode(ReductionPlan.self, from: reductionPlanData)
    }

    /// Restarts the plan from today using the current daily goal as the new starting point.
    /// Called when the user changes the daily goal while reduction mode is already on,
    /// so the trajectory reflects the revised baseline rather than a stale snapshot.
    private func restartPlanWithCurrentGoal() {
        guard reductionModeEnabled,
              let encoded = try? JSONEncoder().encode(ReductionPlan(
                  startDate: Date(),
                  startingGoal: dailyPuffGoal,
                  weeklyReductionPercent: Double(weeklyReductionPercent),
                  minimumFloor: minimumFloor
              ))
        else { return }
        reductionPlanData = encoded
    }

    /// Saves an updated plan to UserDefaults, preserving the original start date and goal.
    /// Called when the user adjusts weekly % or floor while reduction mode is already on.
    private func updateStoredPlan() {
        guard reductionModeEnabled,
              let existing = currentReductionPlan,
              let encoded = try? JSONEncoder().encode(ReductionPlan(
                  startDate: existing.startDate,
                  startingGoal: existing.startingGoal,
                  weeklyReductionPercent: Double(weeklyReductionPercent),
                  minimumFloor: minimumFloor
              ))
        else { return }
        reductionPlanData = encoded
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
                    // Stepper with an embedded TextField lets the user both type a value
                    // directly and use the +/- buttons for fine-grained adjustment.
                    // TextField uses value:format: to bind directly to the Int without
                    // manual string conversion. The onChange clamps values typed outside
                    // the allowed range before they are persisted.
                    Stepper(value: $dailyPuffGoal, in: 1...999) {
                        HStack {
                            Text("Daily Puff Goal")
                                .font(.body)
                            Spacer()
                            TextField("", value: $dailyPuffGoal, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: dailyPuffGoal) { _, newValue in
                        let clamped = min(max(newValue, 1), 999)
                        if clamped != newValue { dailyPuffGoal = clamped }
                        restartPlanWithCurrentGoal()
                    }
                } header: {
                    // Section header appears above the section in small caps
                    Text("Target")
                } footer: {
                    // Section footer appears below the section in smaller, secondary text
                    // Use footer for explanatory text or help content
                    Text("Set your target number of puffs per day. This helps you track your progress toward reducing usage.")
                }

                // Reduction Mode section
                Section {
                    Toggle("Auto-Reduce Goal", isOn: Binding(
                        get: { reductionModeEnabled },
                        set: { enabled in
                            if enabled {
                                // Snapshot the current daily goal as the plan's starting point.
                                // weeklyReductionPercent and minimumFloor are read from @AppStorage.
                                if let encoded = try? JSONEncoder().encode(ReductionPlan(
                                    startDate: Date(),
                                    startingGoal: dailyPuffGoal,
                                    weeklyReductionPercent: Double(weeklyReductionPercent),
                                    minimumFloor: minimumFloor
                                )) {
                                    reductionPlanData = encoded
                                }
                                reductionModeEnabled = true
                            } else {
                                reductionModeEnabled = false
                                // Current goal is kept as-is — user decides whether to adjust manually.
                            }
                        }
                    ))

                    if reductionModeEnabled {
                        Stepper(value: $weeklyReductionPercent, in: 1...20) {
                            HStack {
                                Text("Weekly Reduction")
                                Spacer()
                                Text("\(weeklyReductionPercent)%")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onChange(of: weeklyReductionPercent) { _, _ in updateStoredPlan() }

                        Stepper(value: $minimumFloor, in: 0...999) {
                            HStack {
                                Text("Lowest Daily Goal")
                                Spacer()
                                TextField("", value: $minimumFloor, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                    .foregroundStyle(.secondary)
                                Text("puffs/day")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onChange(of: minimumFloor) { _, newValue in
                            let clamped = min(max(newValue, 0), 999)
                            if clamped != newValue { minimumFloor = clamped }
                            updateStoredPlan()
                        }

                        // Status row
                        if let plan = currentReductionPlan {
                            if plan.isComplete {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Plan complete — goal reached!")
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.vertical, 2)
                            } else {
                                let weekNum = plan.weeksElapsed() + 1
                                let nextDate = plan.nextReductionDate()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Week \(weekNum) — \(plan.currentWeekTarget()) puffs/day target")
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                    Text("Next reduction: \(nextDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                } header: {
                    Text("Reduction Mode")
                } footer: {
                    if reductionModeEnabled {
                        Text("Each week, your daily goal reduces by the set percentage. It will never go below the lowest daily goal you set here. Your reduction trajectory is shown on the home screen.")
                    } else {
                        Text("Automatically reduce your daily goal each week using a compounding percentage.")
                    }
                }

                // Developer section — stripped from release builds automatically.
                // Backdates the plan's startDate so the app behaves as if N weeks
                // have elapsed, letting you walk through the full reduction trajectory
                // and test the completion state without waiting in real time.
                #if DEBUG
                Section {
                    Stepper(value: $debugWeekOffset, in: 0...30) {
                        HStack {
                            Text("Simulate week offset")
                            Spacer()
                            Text(debugWeekOffset == 0 ? "Off" : "+\(debugWeekOffset) wks")
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button("Apply to plan") {
                        guard let existing = currentReductionPlan,
                              let backdated = Calendar.current.date(
                                  byAdding: .weekOfYear,
                                  value: -debugWeekOffset,
                                  to: Date()
                              ),
                              let encoded = try? JSONEncoder().encode(ReductionPlan(
                                  startDate: backdated,
                                  startingGoal: existing.startingGoal,
                                  weeklyReductionPercent: existing.weeklyReductionPercent,
                                  minimumFloor: existing.minimumFloor
                              ))
                        else { return }
                        reductionPlanData = encoded
                    }
                    .disabled(currentReductionPlan == nil || debugWeekOffset == 0)
                    Button("Reset plan to today", role: .destructive) {
                        guard let existing = currentReductionPlan,
                              let encoded = try? JSONEncoder().encode(ReductionPlan(
                                  startDate: Date(),
                                  startingGoal: existing.startingGoal,
                                  weeklyReductionPercent: existing.weeklyReductionPercent,
                                  minimumFloor: existing.minimumFloor
                              ))
                        else { return }
                        reductionPlanData = encoded
                        debugWeekOffset = 0
                    }
                    .disabled(currentReductionPlan == nil)
                } header: {
                    Text("Developer")
                } footer: {
                    Text("Debug only — not included in release builds. Shifts the plan start date backwards to simulate time passing.")
                }
                #endif

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
