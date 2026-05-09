import SwiftUI
import GameFeature

struct ContentView: View {
    var body: some View {
        NavigationStack {
            GameScreen()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}
