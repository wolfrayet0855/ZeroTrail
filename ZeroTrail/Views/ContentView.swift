//contentview

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var isSendingMessage = false  // Track if message sending is active
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 600 {
                HStack {
                    // Sidebar for larger screens
                    ChatSidebarView(
                        chatSessions: $viewModel.chatSessions,
                        onSelect: { session in viewModel.selectChatSession(session) },
                        onDelete: { ids in viewModel.deleteChatSessions(byIds: ids) },
                        onRename: { id, newName in viewModel.renameChatSession(byId: id, newName: newName) }
                    )
                    Divider()
                    mainChatView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                // For smaller screens, use a navigation-based layout
                NavigationView {
                    mainChatView

                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    viewModel.showChatSessions = true
                                }) {
                                    Image(systemName: "sidebar.left")
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                HStack {
                                    Button(action: {
                                        viewModel.clearChat()
                                    }) {
                                        Image(systemName: "trash")
                                    }
                                    Button(action: {
                                        viewModel.saveCurrentChat(withTitle: "Chat on \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short))")
                                    }) {
                                        Image(systemName: "square.and.arrow.down")
                                    }
                                }
                            }
                        }
                        .sheet(isPresented: $viewModel.showChatSessions) {
                            ChatSidebarView(
                                chatSessions: $viewModel.chatSessions,
                                onSelect: { session in
                                    viewModel.selectChatSession(session)
                                    viewModel.showChatSessions = false
                                },
                                onDelete: { ids in viewModel.deleteChatSessions(byIds: ids) },
                                onRename: { id, newName in viewModel.renameChatSession(byId: id, newName: newName) }
                            )
                        }
                }
            }
        }
    }
    
    private var mainChatView: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.isUser {
                                Spacer()
                            }
                            Text(message.content)
                                .padding(10)
                                .background(message.isUser ? Color.blue : Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                            if !message.isUser {
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)").foregroundColor(.red)
            }
            
            // Expanded input area with "Enter to Send" functionality
            HStack {
                TextField("Type your message...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: isSendingMessage ? "stop.circle" : "paperplane.fill")
                        .foregroundColor(isSendingMessage ? .red : .blue)
                        .padding()
                }
                .disabled(viewModel.inputText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            viewModel.receiveMessage("Welcome to the chat!")
        }
    }

    private func sendMessage() {
        if !viewModel.inputText.isEmpty {
            isSendingMessage = true
            viewModel.sendMessage(viewModel.inputText)
            viewModel.inputText = ""
        }
    }
}

#Preview {
    ContentView()
}

