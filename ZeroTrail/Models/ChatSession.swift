//
//  ChatSession.swift
//  ZeroTrail
//
//  Created by user on 10/18/24.
//

import Foundation

struct ChatSession: Identifiable {
    let id = UUID()
    let title: String
    var messages: [Message]
}
