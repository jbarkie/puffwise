import SwiftUI

struct ContentView: View {
    // @State holds the array of puffs in memory during runtime.
    // Unlike @AppStorage, @State doesn't automatically persist to disk.
    // We'll manually save/load from UserDefaults using JSON encoding/decoding.
    @State private var puffs: [Puff] = []

    // Key used to store/retrieve puffs from UserDefaults
    private let puffsKey = "puffs"

    // Computed property that filters puffs to only include today's entries.
    // This recalculates automatically whenever 'puffs' changes.
    private var todaysPuffs: [Puff] {
        // Calendar.current gives us the user's calendar (handles timezones, locales, etc.)
        let calendar = Calendar.current
        // Get the current date
        let now = Date()

        // Filter the puffs array to only include items from today
        return puffs.filter { puff in
            // isDate(_:inSameDayAs:) compares two dates to see if they're on the same day
            // This handles edge cases like midnight crossings correctly
            calendar.isDate(puff.timestamp, inSameDayAs: now)
        }
    }

    // Load puffs from UserDefaults
    // This function reads the stored JSON data and decodes it back into an array of Puff objects.
    private func loadPuffs() {
        // Get the Data object stored under our key
        guard let data = UserDefaults.standard.data(forKey: puffsKey) else {
            // If there's no data (first app launch), keep the empty array
            return
        }

        // Try to decode the JSON data into an array of Puff objects
        do {
            let decoded = try JSONDecoder().decode([Puff].self, from: data)
            puffs = decoded
        } catch {
            // If decoding fails (corrupted data, format change, etc.), log the error
            // and keep the empty array
            print("Failed to load puffs: \(error)")
        }
    }

    // Save puffs to UserDefaults
    // This function encodes the puffs array to JSON and stores it to disk.
    private func savePuffs() {
        do {
            // Encode the puffs array to JSON Data
            let data = try JSONEncoder().encode(puffs)
            // Save the data to UserDefaults under our key
            UserDefaults.standard.set(data, forKey: puffsKey)
        } catch {
            // If encoding fails (should be rare), log the error
            print("Failed to save puffs: \(error)")
        }
    }

    var body: some View {
        // NavigationStack is the modern SwiftUI container for navigation (iOS 16+).
        // It replaces the older NavigationView and provides better control over navigation flow.
        // Everything inside NavigationStack can use navigation features like NavigationLink.
        NavigationStack {
            VStack(spacing: 30) {
                // App header with icon and title
                VStack(spacing: 10) {
                    Image(systemName: "wind")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                    Text("Puffwise")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Spacer()

                // Puff counter display
                VStack(spacing: 8) {
                    Text("Today's Puffs")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    // Display today's count using the filtered array.
                    // Because todaysPuffs is a computed property, this updates automatically
                    // whenever a new puff is added or when the day changes.
                    Text("\(todaysPuffs.count)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(.primary)
                }

                // Main action button
                Button(action: {
                    // Create a new Puff with the current timestamp and append it to the array.
                    // The Puff initializer defaults to Date() (current time) and a new UUID.
                    puffs.append(Puff())
                    // Manually save to UserDefaults after modifying the array
                    // SwiftUI detects the @State change and re-renders the UI automatically
                    savePuffs()
                }) {
                    // Button content - label and icon
                    Label("Log Puff", systemImage: "plus.circle.fill")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 40)
                        .background(.blue)
                        .cornerRadius(16)
                }

                Spacer()
            }
            .padding()
            // .navigationTitle sets the title in the navigation bar
            // This is a required part of the NavigationStack pattern
            .navigationTitle("Today")
            // .toolbar lets us add items to the navigation bar
            // Common placements: .topBarTrailing (top-right), .topBarLeading (top-left), .bottomBar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // NavigationLink creates a button that navigates to another view
                    // The destination parameter specifies which view to show
                    // This is declarative navigation - we describe where to go, not how
                    NavigationLink(destination: HistoryView()) {
                        // SF Symbols provide thousands of icons
                        // "chart.bar" is perfect for representing historical data
                        Label("History", systemImage: "chart.bar")
                    }
                }
            }
            // .onAppear is called when the view first appears on screen
            // We use it to load our saved puffs from UserDefaults
            .onAppear {
                loadPuffs()
            }
        }
    }
}

#Preview {
    ContentView()
}
