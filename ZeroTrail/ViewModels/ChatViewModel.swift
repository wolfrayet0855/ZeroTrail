//
//  ChatViewModel.swift
//  ZeroTrail
//
//  Created by user on 10/18/24.
//
import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var chatSessions: [ChatSession] = []
    @Published var showChatSessions: Bool = false
    @Published var selectedChatSession: ChatSession?
    @Published var errorMessage: String?
    @Published var isProcessingChat: Bool = false  // Track if chat is ongoing
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        let userMessage = Message(content: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        isProcessingChat = true
        
        Task {
            do {
                let apiKey: String = try Configuration.value(for: "API_KEY")
                let api = ChatGPTAPI(apiKey: apiKey)
                let stream = try await api.sendMessageStream(text: text)
                
                await MainActor.run {
                    self.messages.append(Message(content: "", isUser: false))
                }

                for try await line in stream {
                    await MainActor.run {
                        if let lastIndex = self.messages.indices.last {
                            self.messages[lastIndex].content += line
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
            
            await MainActor.run {
                self.isProcessingChat = false  // Reset to idle state
            }
        }
    }

    func stopChat() {
        // Logic to stop ongoing chat processing, if possible
        isProcessingChat = false
        // Additional implementation depends on how to cancel the API task
    }

    func receiveMessage(_ text: String) {
        let chatMessage = Message(content: text, isUser: false)
        messages.append(chatMessage)
    }

    func clearChat() {
        messages.removeAll()
    }

    func saveCurrentChat(withTitle title: String) {
        let session = ChatSession(title: title, messages: messages)
        chatSessions.append(session)
        clearChat()
    }

    func selectChatSession(_ session: ChatSession) {
        selectedChatSession = session
        messages = session.messages
    }

    func deleteChatSessions(byIds ids: [UUID]) {
        chatSessions.removeAll { session in
            ids.contains(session.id)
        }
    }

    func renameChatSession(byId id: UUID, newName: String) {
        if let index = chatSessions.firstIndex(where: { $0.id == id }) {
            chatSessions[index].title = newName
            // Force refresh by reassigning array (SwiftUI trick)
            chatSessions = chatSessions.map { $0 }
        }
    }
}
