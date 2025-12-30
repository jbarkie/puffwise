//
//  HistoryView.swift
//  Puffwise
//
//  View for displaying historical puff tracking data with bar chart visualization.
//  Shows puff counts as both an interactive chart and detailed list, grouped by
//  day, week, or month based on user selection.
//

import SwiftUI
import Charts

/// A view that displays historical puff tracking data grouped by day
///
/// This view receives puff data from ContentView via a `@Binding` and displays
/// it in a list format. Each row shows the date and total puff count for that day.
///
/// **SwiftUI Concepts:**
/// - `@Binding`: A two-way connection to data owned by a parent view. Changes to the
///   binding in this view will be reflected in the parent (ContentView).
/// - `List`: A scrollable container that displays rows of data, similar to UITableView.
/// - `ForEach`: Iterates over a collection and creates views for each element.
struct HistoryView: View {
    // @Binding creates a two-way connection to the puffs array in ContentView
    // The $ prefix when passing data creates a binding
    @Binding var puffs: [Puff]

    // @State stores the currently selected grouping period for filtering
    // Defaults to .day view on each app launch
    // @State is for view-local data that can change over time
    @State private var selectedPeriod: PuffGroupPeriod = .day

    // State variable to track which puff is being edited
    // When set to a non-nil value, the edit sheet is presented
    // Using Puff? (optional) allows us to use .sheet(item:) for automatic presentation
    @State private var puffToEdit: Puff?

    // MARK: - Chart View

    /// Empty state view shown when there is no puff data to display.
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No data yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Start logging puffs to see your chart")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    /// A computed property that generates the bar chart visualization.
    ///
    /// This creates a bar chart using Swift Charts, Apple's declarative charting framework
    /// introduced in iOS 16. Charts uses a similar builder syntax to SwiftUI views.
    ///
    /// **Swift Charts Concepts:**
    /// - `Chart { }`: Container that defines the chart. Similar to VStack/HStack for views.
    /// - `ForEach`: Iterates over data (same as SwiftUI's ForEach for views)
    /// - `BarMark`: Defines a vertical bar in the chart
    /// - `.foregroundStyle()`: Sets the bar color
    /// - `.annotation()`: Adds labels to bars for displaying exact values
    /// - `AxisMarks`: Customizes the appearance of chart axes
    ///
    /// The chart displays puff counts over time, grouped by the selected period (day/week/month).
    /// When no data exists, it shows a friendly empty state with guidance for the user.
    private var chartView: some View {
        // Get the grouped data based on the current filter
        let groupedData = puffs.groupedBy(selectedPeriod)

        return Group {
            if groupedData.isEmpty {
                emptyChartView
            } else {
                // Chart with data
                // The Chart container works like a SwiftUI view container (VStack, HStack, etc.)
                Chart {
                    // ForEach iterates over each PuffGroup and creates a BarMark for it
                    ForEach(groupedData) { group in
                        // BarMark creates a single vertical bar in the chart
                        // x: determines the horizontal position (the date)
                        // y: determines the bar height (the puff count)
                        // unit: tells Charts how to group dates on the x-axis
                        BarMark(
                            x: .value("Date", group.date, unit: unitForPeriod(selectedPeriod)),
                            y: .value("Puffs", group.count)
                        )
                        // Set the bar color to blue, matching the app's primary action color
                        .foregroundStyle(.blue)
                    }
                }
                // Customize the x-axis appearance
                // AxisMarks with .automatic lets Swift Charts intelligently choose
                // which dates to show based on the data range and available space
                .chartXAxis {
                    AxisMarks(values: .automatic)
                }
                // Customize the y-axis appearance
                // Position .leading puts the y-axis on the left side
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                // Set a fixed height for the chart
                // 200 points provides good visibility without dominating the screen
                .frame(height: 200)
                // Add padding around the chart for breathing room
                .padding()
            }
        }
    }

    var body: some View {
        // VStack stacks the chart and list vertically
        // spacing: 0 ensures no gap between the chart and list
        VStack(spacing: 0) {
            // Chart section at the top
            // This shows the visual representation of puff trends
            chartView

            // List section below
            // This shows the detailed data for each period, now with expandable individual puffs
            // List creates a scrollable list view
            List {
                // ForEach iterates over the grouped puffs
                // PuffGroup conforms to Identifiable, so ForEach can use its id automatically
                ForEach(puffs.groupedBy(selectedPeriod)) { group in
                    // Section creates a grouped section with a header
                    // This provides a two-level hierarchy: groups and individual puffs
                    Section {
                        // Inner ForEach iterates over individual puffs within this group
                        // Each puff can be tapped to edit or swiped to delete
                        ForEach(group.puffs) { puff in
                            // HStack arranges the puff's timestamp horizontally
                            HStack {
                                // Display the puff's exact timestamp
                                // For daily view, show time; for weekly/monthly, show full date+time
                                Text(timestampFormatter(for: selectedPeriod).string(from: puff.timestamp))
                                    .font(.body)

                                Spacer()

                                // Visual indicator that the row is tappable
                                Image(systemName: "pencil.circle")
                                    .font(.body)
                                    .foregroundColor(.blue.opacity(0.6))
                            }
                            // Tap gesture to edit this puff
                            .onTapGesture {
                                puffToEdit = puff
                            }
                            // Swipe actions for delete
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deletePuff(puff)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        // Section header showing the period date and total count
                        HStack {
                            Text(formatterForPeriod(selectedPeriod).string(from: group.date))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(group.count) puff\(group.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        // navigationTitle appears in the navigation bar
        // This is a key part of NavigationStack hierarchy
        .navigationTitle("History")
        // navigationBarTitleDisplayMode controls how the title appears
        // .large gives the iOS standard large title that collapses on scroll
        .navigationBarTitleDisplayMode(.large)
        // toolbar allows us to add controls to the navigation bar
        .toolbar {
            // ToolbarItem with .principal placement puts the control in the center
            // of the navigation bar (below the title when using large display mode)
            ToolbarItem(placement: .principal) {
                // Picker provides a selection interface for the grouping period
                // The $ prefix creates a binding to selectedPeriod, allowing the
                // Picker to both read and write the value
                // This picker controls both the chart and list views simultaneously
                Picker("Period", selection: $selectedPeriod) {
                    // Each Text+tag pair defines an option in the picker
                    Text("Day").tag(PuffGroupPeriod.day)
                    Text("Week").tag(PuffGroupPeriod.week)
                    Text("Month").tag(PuffGroupPeriod.month)
                }
                // .segmented style gives us the iOS-style segmented control
                // This is the horizontal button group commonly used for filters
                .pickerStyle(.segmented)
            }
        }
        // Sheet presentation for editing a puff
        // .sheet(item:) automatically presents when puffToEdit becomes non-nil
        // and dismisses when it becomes nil. The item parameter provides the puff to edit.
        .sheet(item: $puffToEdit) { puff in
            EditPuffView(originalPuff: puff) { editedPuff in
                updatePuff(editedPuff)
            }
        }
    }

    // MARK: - Helper Methods

    /// Returns the appropriate DateFormatter based on the selected grouping period.
    ///
    /// This helper method selects the correct formatter to display dates in a way
    /// that matches the grouping period. For example, daily groups show "Jan 15, 2024"
    /// while weekly groups show "Week of Jan 15, 2024".
    ///
    /// - Parameter period: The grouping period to get a formatter for
    /// - Returns: The DateFormatter appropriate for the period
    private func formatterForPeriod(_ period: PuffGroupPeriod) -> DateFormatter {
        switch period {
        case .day:
            return DateFormatter.dayFormatter
        case .week:
            return DateFormatter.weekFormatter
        case .month:
            return DateFormatter.monthFormatter
        }
    }

    /// Returns the appropriate Calendar.Component unit for chart x-axis formatting.
    ///
    /// Swift Charts uses Calendar.Component to understand how to group and label dates
    /// on the x-axis. This ensures dates display at the right granularity.
    ///
    /// For example:
    /// - `.day` returns `Calendar.Component.day` for daily grouping
    /// - `.week` returns `Calendar.Component.weekOfYear` for weekly grouping
    /// - `.month` returns `Calendar.Component.month` for monthly grouping
    ///
    /// This component is passed to BarMark's x-axis `.value()` method to tell the chart
    /// framework how to interpret and display the date values.
    ///
    /// - Parameter period: The grouping period being displayed
    /// - Returns: The Calendar.Component unit for the x-axis
    private func unitForPeriod(_ period: PuffGroupPeriod) -> Calendar.Component {
        switch period {
        case .day:
            return .day
        case .week:
            return .weekOfYear
        case .month:
            return .month
        }
    }

    // MARK: - Edit/Delete Methods

    /// Updates a puff with a new timestamp while preserving its ID.
    ///
    /// This method follows the immutable pattern for the Puff model. Rather than
    /// modifying the puff directly (which isn't possible since properties are `let`),
    /// we replace the puff in the array with a new one that has the same ID but
    /// an updated timestamp.
    ///
    /// The update propagates through the @Binding to ContentView, where the onChange
    /// modifier will automatically persist the change to UserDefaults.
    ///
    /// - Parameter editedPuff: The new puff with updated timestamp (same ID as original)
    private func updatePuff(_ editedPuff: Puff) {
        // Find the index of the puff with this ID
        if let index = puffs.firstIndex(where: { $0.id == editedPuff.id }) {
            // Replace the old puff with the edited one
            // This triggers SwiftUI to update all dependent views (charts, lists, counts)
            puffs[index] = editedPuff
        }
        // Clear the edit state (though the sheet will dismiss automatically)
        puffToEdit = nil
    }

    /// Deletes a puff from the array.
    ///
    /// This method removes the puff with the matching ID from the puffs array.
    /// The deletion propagates through the @Binding to ContentView, where the
    /// onChange modifier will automatically persist the change to UserDefaults.
    ///
    /// Groups and charts automatically update via SwiftUI's reactivity system.
    /// If this is the last puff in a group, the entire section will disappear.
    ///
    /// - Parameter puff: The puff to delete
    private func deletePuff(_ puff: Puff) {
        // Remove all puffs with this ID (should only be one due to UUID uniqueness)
        puffs.removeAll { $0.id == puff.id }
    }

    /// Returns a DateFormatter appropriate for displaying individual puff timestamps.
    ///
    /// The format varies based on the grouping period:
    /// - **Day view**: Show only time (e.g., "2:30 PM") since all puffs are from the same day
    /// - **Week/Month view**: Show both date and time (e.g., "Jan 15, 2:30 PM")
    ///
    /// This creates a more readable display than always showing the full timestamp.
    ///
    /// - Parameter period: The current grouping period
    /// - Returns: A DateFormatter configured for the period
    private func timestampFormatter(for period: PuffGroupPeriod) -> DateFormatter {
        let formatter = DateFormatter()
        switch period {
        case .day:
            // For daily view, only show the time since the date is in the section header
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        case .week, .month:
            // For weekly/monthly view, show both date and time for clarity
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        }
        return formatter
    }
}

// MARK: - Preview
// SwiftUI previews let you see the view in Xcode without running the full app
// This is one of SwiftUI's killer features for rapid development
#Preview {
    // Create sample puff data for preview
    // We need @State to create a binding for the preview
    struct PreviewWrapper: View {
        @State private var samplePuffs: [Puff] = [
            Puff(timestamp: Date()),
            Puff(timestamp: Date().addingTimeInterval(-3600)),
            Puff(timestamp: Date().addingTimeInterval(-86400)),
            Puff(timestamp: Date().addingTimeInterval(-172800))
        ]

        var body: some View {
            NavigationStack {
                HistoryView(puffs: $samplePuffs)
            }
        }
    }

    return PreviewWrapper()
}
