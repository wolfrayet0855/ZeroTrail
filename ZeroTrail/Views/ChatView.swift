import SwiftUI

struct ChatView: View {
    @Binding var messages: [Message]
    @Binding var inputText: String
    var onSend: (String) -> Void
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                }
                                Text(message.content)
                                    .padding(10)
                                    .background(message.isUser ? Color.accentColor : Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(message.isUser ? .white : .primary)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                                if !message.isUser {
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .onChange(of: messages.count) { oldCount, newCount in
                        if newCount > oldCount, let lastMessage = messages.last {
                            withAnimation {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }

                }
            }
            .background(Color(UIColor.systemBackground))
            
            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    .submitLabel(.send)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        onSend(inputText)
        inputText = ""
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ChatView(messages: .constant([]), inputText: .constant(""), onSend: { _ in })
}
