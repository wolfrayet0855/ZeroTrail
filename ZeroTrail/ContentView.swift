import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            ChatView(messages: $viewModel.messages, inputText: $viewModel.inputText, onSend: viewModel.sendMessage)
            
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            }
        }
        .onAppear {
            // Example of sending an initial message if needed
            viewModel.receiveMessage("Welcome to the chat!")
        }
    }
}

#Preview {
    ContentView()
}
