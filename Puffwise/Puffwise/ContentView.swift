import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "wind")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Puffwise")
                .font(.largeTitle)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
