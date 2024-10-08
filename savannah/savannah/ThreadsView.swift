//
//  ThreadsView.swift
//  savannah
//
//  Created by Kemal Erol on 11/09/2024.
//

import SwiftUI
import Supabase

struct ThreadsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var conversations: [Conversation] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                } else if conversations.isEmpty {
                    Text("No conversations yet")
                        .foregroundColor(.gray)
                } else {
                    List(conversations) { conversation in
                        NavigationLink(destination: AgentView(conversationId: conversation.conversationId, agentNo: conversation.agentId ?? 0)) {
                            ConversationRow(conversation: conversation)
                        }
                    }
                }
            }
            .navigationTitle("Threads")
            .onAppear(perform: loadConversations)
        }
    }

    private func loadConversations() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                guard let userId = authViewModel.userId else {
                    throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID is not available"])
                }
                conversations = try await SupabaseManager.shared.fetchConversations(for: userId)
                isLoading = false
            } catch {
                print("Error loading conversations: \(error)")
                errorMessage = "Failed to load conversations: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

struct Conversation: Identifiable, Codable {
    let id: UUID
    let conversationId: Int
    let userId: UUID?
    let agentId: Int?
    let lastMessage: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case userId = "user_id"
        case agentId = "agent_id"
        case lastMessage = "content"
        case createdAt = "created_at"
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var agent: Agent? {
        AgentList.getAgent(by: conversation.agentId ?? 0)
    }

    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: agent?.imageUrl ?? "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(agent?.name ?? "Unknown Agent")
                    .font(.headline)
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Text(formattedDate(from: conversation.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func formattedDate(from dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

struct ThreadsView_Previews: PreviewProvider {
    static var previews: some View {
        ThreadsView()
            .environmentObject(AuthViewModel(supabase: SupabaseClient(supabaseURL: URL(string: "https://example.com")!, supabaseKey: "dummy-key")))
    }
}