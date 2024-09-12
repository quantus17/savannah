//
//  SupabaseManager.swift
//  savannah
//
//  Created by Kemal Erol on 11/09/2024.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    private let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseKey
        )
    }
    
    func startNewConversation(for agentId: Int, userId: UUID) async throws -> Int {
        let query = client
            .from("conversations")
            .select("conversation_id")
            .eq("agent_id", value: agentId)
            .eq("user_id", value: userId)
            .order("conversation_id", ascending: false)
            .limit(1)
        
        let response = try await query.execute()
        
        struct ConversationIdResponse: Codable {
            let conversation_id: Int
        }
        
        let conversationIdResponses = try JSONDecoder().decode([ConversationIdResponse].self, from: response.data)
        let newConversationId = (conversationIdResponses.first?.conversation_id ?? 0) + 1
        
        return newConversationId
    }
    
    func saveMessage(userId: UUID, agentId: Int, conversationId: Int, qandaId: Int, role: String, content: String, part: Int) async throws {
        struct MessageData: Encodable {
            let user_id: String
            let agent_id: Int
            let conversation_id: Int
            let qanda_id: Int  // Changed this line
            let role: String
            let content: String
            let part: Int
        }

        let messageData = MessageData(
            user_id: userId.uuidString,
            agent_id: agentId,
            conversation_id: conversationId,
            qanda_id: qandaId,
            role: role,
            content: content,
            part: part
        )

        let _ = try await client
            .from("conversations")
            .insert(messageData)
            .execute()
    }
    
    func getLatestQandaId(for conversationId: Int) async throws -> Int {
        let query = client
            .from("conversations")
            .select("qanda_id")
            .eq("conversation_id", value: conversationId)
            .order("qanda_id", ascending: false)
            .limit(1)
        
        let response = try await query.execute()
        
        struct QandaIdResponse: Codable {
            let qanda_id: Int
        }
        
        let qandaIdResponses = try JSONDecoder().decode([QandaIdResponse].self, from: response.data)
        return qandaIdResponses.first?.qanda_id ?? 0
    }
    
    func fetchConversations(for userId: UUID) async throws -> [Conversation] {
        let response = try await client
            .from("conversations")
            .select("id, conversation_id, user_id, agent_id, content, created_at")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
        
        print("Raw Supabase response: \(String(describing: response.data))")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let allMessages = try decoder.decode([Conversation].self, from: response.data)
        
        // Group by conversation_id and take the most recent message for each
        let groupedConversations = Dictionary(grouping: allMessages, by: { $0.conversationId })
        let uniqueConversations = groupedConversations.values.compactMap { $0.first }
        
        return uniqueConversations.sorted(by: { $0.createdAt > $1.createdAt })
    }
    
    func fetchMessages(for conversationId: Int) async throws -> [Message] {
        print("Fetching messages for conversation ID: \(conversationId)")
        let response = try await client
            .from("conversations")
            .select("*")
            .eq("conversation_id", value: conversationId)
            .order("created_at")
            .execute()
        
        print("Raw Supabase response: \(String(describing: response.data))")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let messages = try decoder.decode([Message].self, from: response.data)
            print("Decoded \(messages.count) messages")
            return messages
        } catch {
            print("Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type '\(type)': \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value of type '\(type)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                default:
                    print("Other decoding error: \(decodingError)")
                }
            }
            throw error
        }
    }
}
