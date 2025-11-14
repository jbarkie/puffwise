import SwiftUI

struct ContentView: View {
    // @AppStorage is a property wrapper that persists data to UserDefaults.
    // Like @State, it tells SwiftUI to watch this variable and re-render when it changes.
    // Unlike @State, the value survives app restarts - it's saved to disk automatically.
    // The string "puffCount" is the key used to store/retrieve the value from UserDefaults.
    // The initial value (0) is used only on the very first app launch.
    @AppStorage("puffCount") private var puffCount: Int = 0

    var body: some View {
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

                // Display the current count - updates automatically when puffCount changes
                Text("\(puffCount)")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.primary)
            }

            // Main action button
            Button(action: {
                // When tapped, increment the puffCount by 1
                // SwiftUI detects the @State change and updates the UI automatically
                puffCount += 1
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
    }
}

#Preview {
    ContentView()
}
