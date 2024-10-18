import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var errorMessage: String?
    @Published var inputText: String = ""
    
    func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        let userMessage = Message(content: text, isUser: true)
        messages.append(userMessage)
        inputText = ""
        
        Task {
            do {
                let apiKey: String = try Configuration.value(for: "API_KEY")
                let api = ChatGPTAPI(apiKey: apiKey)
                let stream = try await api.sendMessageStream(text: text)
                
                // Clear existing partial response before starting
                await MainActor.run {
                    self.messages.append(Message(content: "", isUser: false))
                }

                for try await line in stream {
                    await MainActor.run {
                        if let lastIndex = self.messages.indices.last {
                            // Update the last message instead of trying to maintain a local variable
                            self.messages[lastIndex].content += line
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func receiveMessage(_ text: String) {
        let chatMessage = Message(content: text, isUser: false)
        messages.append(chatMessage)
    }
}
