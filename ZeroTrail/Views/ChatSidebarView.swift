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
    var onDelete: ([UUID]) -> Void
    var onRename: (UUID, String) -> Void

    @State private var selectedChats = Set<UUID>()
    @State private var editingSessionId: UUID? = nil
    @State private var newName: String = ""

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List(selection: $selectedChats) {
                    ForEach(chatSessions) { session in
                        HStack {
                            if editingSessionId == session.id {
                                TextField("Rename chat", text: $newName, onCommit: {
                                    onRename(session.id, newName)
                                    editingSessionId = nil // Exit edit mode
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(5)
                            } else {
                                Text(session.title)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(5)
                                    .onTapGesture {
                                        onSelect(session)
                                    }
                                    .onLongPressGesture {
                                        newName = session.title // Prepare to edit
                                        editingSessionId = session.id // Enter edit mode
                                    }
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                onDelete([session.id])
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        let idsToDelete = indexSet.map { chatSessions[$0].id }
                        onDelete(idsToDelete)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Saved Chats") // Main title
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if !selectedChats.isEmpty {
                                onDelete(Array(selectedChats))
                                selectedChats.removeAll()
                            }
                        }) {
                            Image(systemName: "trash")
                        }
                        .disabled(selectedChats.isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    ChatSidebarView(
        chatSessions: .constant([]),
        onSelect: { _ in },
        onDelete: { _ in },
        onRename: { _, _ in }
    )
}
