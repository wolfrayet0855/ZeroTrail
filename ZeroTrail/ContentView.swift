import SwiftUI

struct ContentView: View {
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let apiKey: String = try Configuration.value(for: "API_KEY")
                    let api = ChatGPTAPI(apiKey: apiKey)
                    let stream = try await api.sendMessageStream(text: "Who is James Bond?")
                    for try await line in stream {
                        print(line)
                    }
                } catch {
                    errorMessage = error.localizedDescription
                    print("Error: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
