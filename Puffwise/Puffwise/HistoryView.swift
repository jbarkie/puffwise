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

    var body: some View {
        // Group puffs by day using the extension from PuffGrouping.swift
        // This returns an array of PuffGroup objects, sorted newest first
        let groupedPuffs = puffs.groupedByDay()

        // List creates a scrollable list view
        List {
            // ForEach iterates over the grouped puffs
            // PuffGroup conforms to Identifiable, so ForEach can use its id automatically
            ForEach(groupedPuffs) { group in
                // HStack arranges views horizontally
                HStack {
                    // Display the formatted date on the left
                    Text(DateFormatter.dayFormatter.string(from: group.date))
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
