//
//  HistoryView.swift
//  Puffwise
//
//  Placeholder view for historical puff tracking data.
//  This view will eventually display puff counts organized by day/week/month.
//

import SwiftUI

/// A view that displays historical puff tracking data
///
/// This is a placeholder implementation that establishes the navigation structure.
/// Future iterations will add:
/// - List of past days with puff counts
/// - Data grouping and aggregation logic
/// - Date formatting and visual styling
/// - Charts and visualizations
struct HistoryView: View {
    var body: some View {
        // VStack centers content vertically
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("History View")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Coming soon: View your puff tracking history organized by day")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
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
    // Wrap in NavigationStack for preview so we can see the navigation bar
    NavigationStack {
        HistoryView()
    }
}
