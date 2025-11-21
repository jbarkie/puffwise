//
//  HistoryView.swift
//  Puffwise
//
//  View for displaying historical puff tracking data.
//  Shows puff counts organized by day in a list format.
//

import SwiftUI

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

    var body: some View {
        // List creates a scrollable list view
        List {
            // ForEach iterates over the grouped puffs
            // PuffGroup conforms to Identifiable, so ForEach can use its id automatically
            ForEach(puffs.groupedBy(selectedPeriod)) { group in
                // HStack arranges views horizontally
                HStack {
                    // Display the formatted date on the left using the appropriate formatter
                    Text(formatterForPeriod(selectedPeriod).string(from: group.date))
                        .font(.body)

                    // Spacer pushes content to the edges
                    Spacer()

                    // Display the puff count on the right
                    Text("\(group.count)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
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
