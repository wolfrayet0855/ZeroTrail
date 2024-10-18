import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        HStack {
            // Sidebar for saved chat sessions
            ChatSidebarView(chatSessions: $viewModel.chatSessions, onSelect: viewModel.selectChatSession)
            
            VStack {
                // Chat view in the center
                ChatView(messages: $viewModel.messages, inputText: $viewModel.inputText, onSend: viewModel.sendMessage)
                
                // Error message display
                if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)").foregroundColor(.red)
                }
                
                // Buttons for clearing and saving chat
                HStack {
                    Button("Clear Chat") {
                        viewModel.clearChat()
                    }
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(5)
                    
                    Button("Save Chat") {
                        viewModel.saveCurrentChat(withTitle: "Chat on \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))")
                    }
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(5)
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.receiveMessage("Welcome to the chat!")
        }
    }
}

#Preview {
    ContentView()
}

