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

// Add this at the end of the file
struct AgentList {
    static let agents: [Agent] = [
        Agent(
            id: UUID(),
            agentNo: 1,
            name: "Freja Andersen",
            location: "Copenhagen",
            title: "Scandinavian Interior Designer",
            description: "Freja Andersen, 29, is a rising star in Scandinavian interior design. With a degree from the Royal Danish Academy of Fine Arts, she specializes in creating serene, minimalist spaces that embody the essence of hygge.",
            summaryDesc: "Copenhagen-based designer specializing in serene, minimalist Scandinavian interiors.",
            imageUrl: "https://storage.googleapis.com/subgroup-images/02890053-84ab-4c0d-8c40-201bd0712fd2.jpg",
            questions: []
        ),
        Agent(
            id: UUID(),
            agentNo: 2,
            name: "Liam Chen",
            location: "New York City",
            title: "Urban Fashion Stylist",
            description: "Liam Chen, 27, is a trendsetting fashion stylist based in New York City. With a background in street fashion and high-end couture, Liam blends urban edge with luxury to create unique, head-turning looks.",
            summaryDesc: "NYC-based stylist blending street fashion with high-end couture for unique urban looks.",
            imageUrl: "https://storage.googleapis.com/subgroup-images/b19023f1-a857-4a66-ad3f-b52d381079f8.jpg?timestamp=1721548645776",
            questions: []
        ),
        Agent(
            id: UUID(),
            agentNo: 3,
            name: "Sophia Laurent",
            location: "Paris",
            title: "Interior Designer",
            description: "Sophia Laurent, 32, a distinguished interior designer based in Paris. With a masters degree from École Camondo, she has an exquisite blend of classical European design education and a bold, avant-garde approach.",
            summaryDesc: "Paris-based interior designer, blending classical European education from École Camondo with avant-garde design.",
            imageUrl: "https://storage.googleapis.com/subgroup-images/77b4c6eb-2df5-42a5-8202-a57ceb0ec2b1.jpg?timestamp=1715842580622",
            questions: []
        ),
        // Add more agents as needed
    ]
    
    static func getAgent(by agentNo: Int) -> Agent? {
        return agents.first { $0.agentNo == agentNo }
    }
}
