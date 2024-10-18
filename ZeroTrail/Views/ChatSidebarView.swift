//
//  ChatSidebarView.swift
//  ZeroTrail
//
//  Created by user on 10/18/24.
//
import SwiftUI

struct ChatSidebarView: View {
    @Binding var chatSessions: [ChatSession]
    var onSelect: (ChatSession) -> Void
    
    var body: some View {
        VStack {
            Text("Saved Chats").font(.headline).padding(.top)
            
            List(chatSessions) { session in
                Button(action: {
                    onSelect(session)
                }) {
                    Text(session.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(5)
                }
            }
            .listStyle(SidebarListStyle())
            
            Spacer()
        }
        .frame(width: 200)
        .background(Color(UIColor.systemGray6))
        .ignoresSafeArea(edges: .vertical)
    }
}

#Preview {
    ChatSidebarView(chatSessions: .constant([]), onSelect: { _ in })
}
