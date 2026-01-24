//
//  TrashView.swift
//  Puffwise
//
//  View for managing deleted puffs with 24-hour recovery window.
//  Users can restore deleted puffs or permanently remove them.
//

import SwiftUI

/// A view that displays deleted puffs and allows restoration or permanent deletion.
///
/// This view implements the "trash" or "recycle bin" pattern, giving users a safety net
/// for accidental deletions. Puffs remain recoverable for 24 hours before auto-purging.
///
/// **SwiftUI Concepts:**
/// - Uses @Binding to modify both puffs and deletedPuffs arrays in the parent
/// - Implements swipe actions for restore and permanent delete
/// - Shows countdown timers for expiry
/// - Provides empty state when trash is clean
struct TrashView: View {
    // @Binding to the active puffs array (for restoring items)
    @Binding var puffs: [Puff]

    // @Binding to the deleted puffs array (trash contents)
    @Binding var deletedPuffs: [DeletedPuff]

    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if deletedPuffs.isEmpty {
                    // Empty state when trash is clean
                    emptyStateView
                } else {
                    // List of deleted puffs
                    deletedPuffsList
                }
            }
            .navigationTitle("Trash")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Done button to dismiss the sheet
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }

                // Empty trash button (only shown when there are items)
                if !deletedPuffs.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(role: .destructive) {
                            emptyTrash()
                        } label: {
                            Label("Empty Trash", systemImage: "trash.slash")
                        }
                    }
                }
            }
        }
    }

    // MARK: - View Components

    /// Empty state view shown when trash is clean
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trash")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Trash is Empty")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text("Deleted puffs appear here and can be restored within 24 hours")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// List of deleted puffs with restore and permanent delete actions
    private var deletedPuffsList: some View {
        List {
            // Info section explaining auto-purge
            Section {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Deleted puffs are automatically removed after 24 hours")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Deleted puffs section
            Section {
                ForEach(deletedPuffs) { deletedPuff in
                    deletedPuffRow(deletedPuff)
                }
            } header: {
                Text("\(deletedPuffs.count) deleted puff\(deletedPuffs.count == 1 ? "" : "s")")
            }
        }
    }

    /// Individual row for a deleted puff
    private func deletedPuffRow(_ deletedPuff: DeletedPuff) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Puff timestamp
            Text(formatTimestamp(deletedPuff.puff.timestamp))
                .font(.body)
                .foregroundStyle(.primary)

            // Deletion info and time remaining
            HStack {
                Text("Deleted \(formatDeletedTime(deletedPuff.deletedAt))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Time remaining until permanent deletion
                Text(deletedPuff.formattedTimeRemaining())
                    .font(.caption)
                    .foregroundStyle(deletedPuff.isExpired() ? .red : .orange)
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            // Restore action (swipe from left)
            Button {
                restorePuff(deletedPuff)
            } label: {
                Label("Restore", systemImage: "arrow.uturn.backward")
            }
            .tint(.green)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            // Permanent delete action (swipe from right)
            Button(role: .destructive) {
                permanentlyDelete(deletedPuff)
            } label: {
                Label("Delete Forever", systemImage: "trash.slash")
            }
        }
    }

    // MARK: - Helper Methods

    /// Formats a puff timestamp for display
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Formats the deletion time as a relative string
    private func formatDeletedTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// Restores a deleted puff back to the active puffs array
    private func restorePuff(_ deletedPuff: DeletedPuff) {
        // Add the original puff back to active puffs
        puffs.append(deletedPuff.puff)

        // Remove from trash
        deletedPuffs.removeAll { $0.id == deletedPuff.id }
    }

    /// Permanently deletes a puff from trash
    private func permanentlyDelete(_ deletedPuff: DeletedPuff) {
        deletedPuffs.removeAll { $0.id == deletedPuff.id }
    }

    /// Permanently deletes all items in trash
    private func emptyTrash() {
        deletedPuffs.removeAll()
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var samplePuffs: [Puff] = []
        @State private var sampleDeletedPuffs: [DeletedPuff] = [
            DeletedPuff(
                puff: Puff(timestamp: Date().addingTimeInterval(-3600)),
                deletedAt: Date().addingTimeInterval(-1800)
            ),
            DeletedPuff(
                puff: Puff(timestamp: Date().addingTimeInterval(-7200)),
                deletedAt: Date().addingTimeInterval(-3600)
            )
        ]

        var body: some View {
            TrashView(puffs: $samplePuffs, deletedPuffs: $sampleDeletedPuffs)
        }
    }

    return PreviewWrapper()
}
