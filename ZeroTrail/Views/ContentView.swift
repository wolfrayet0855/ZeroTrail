//contentview

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 600 {
                HStack {
                    ChatSidebarView(
                        chatSessions: $viewModel.chatSessions,
                        onSelect: viewModel.selectChatSession,
                        onDelete: viewModel.deleteChatSessions,
                        onRename: viewModel.renameChatSession
                    )
                    Divider()
                    mainChatView
                }
            } else {
                NavigationView {
                    mainChatView
                        .navigationBarTitle("Chat", displayMode: .inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    viewModel.showChatSessions = true
                                }) {
                                    Image(systemName: "sidebar.left")
                                }
                            }
                        }
                        .sheet(isPresented: $viewModel.showChatSessions) {
                            ChatSidebarView(
                                chatSessions: $viewModel.chatSessions,
                                onSelect: viewModel.selectChatSession,
                                onDelete: viewModel.deleteChatSessions,
                                onRename: viewModel.renameChatSession
                            )

                        }
                }
            }
        }
    }
    
    private var mainChatView: some View {
        VStack {
            ChatView(messages: $viewModel.messages, inputText: $viewModel.inputText, onSend: viewModel.sendMessage)
            
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            }
            
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
        .onAppear {
            viewModel.receiveMessage("Welcome to the chat!")
        }
    }
}

#Preview {
    ContentView()
}
