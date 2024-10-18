//
//  Message.swift
//  ZeroTrail
//
//  Created by user on 10/18/24.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()
    var content: String
    let isUser: Bool
}
