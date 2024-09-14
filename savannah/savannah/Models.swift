//
//  Models.swift
//  savannah
//
//  Created by Kemal Erol on 14/09/2024.
//

import Foundation

struct Agent: Identifiable {
    let id: UUID
    let agentNo: Int
    let name: String
    let location: String
    let title: String
    let description: String
    let summaryDesc: String
    let imageUrl: String
    let questions: [String]
}

struct Message: Identifiable, Codable {
    let id: UUID
    let userId: UUID?
    let agentId: Int?
    let conversationId: Int?
    let urlId: String?
    let qandaId: Int?
    let part: Int?
    let role: String?
    var content: String?
    let content2: String?
    let createdAt: Date?
    
    var isUser: Bool {
        return role == "user" || role == "user-image"
    }
    
    var isImage: Bool {
        return role == "user-image"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case agentId = "agent_id"
        case conversationId = "conversation_id"
        case urlId = "url_id"
        case qandaId = "qanda_id"
        case part
        case role
        case content
        case content2
        case createdAt = "created_at"
    }
}

struct ConversationSummary: Identifiable, Codable {
    let id: UUID
    let userId: UUID?
    let agentId: Int?
    let conversationId: Int?
    let content: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case agentId = "agent_id"
        case conversationId = "conversation_id"
        case content
        case createdAt = "created_at"
    }
    
    var lastMessage: String? {
        return content
    }
}
