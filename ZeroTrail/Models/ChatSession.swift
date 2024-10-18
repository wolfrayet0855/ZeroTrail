//
//  ChatSession.swift
//  ZeroTrail
//
//  Created by user on 10/18/24.
//

import Foundation

struct ChatSession: Identifiable {
    let id = UUID()
    var title: String  // Changed from 'let' to 'var'
    var messages: [Message]
}
