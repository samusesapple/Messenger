//
//  Conversation.swift
//  Messenger
//
//  Created by Sam Sung on 2023/05/14.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
