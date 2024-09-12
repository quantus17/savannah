//
//  AgentView.swift
//  savannah
//
//  Created by Kemal Erol on 11/09/2024.
//
 
import SwiftUI
import Supabase  // Add this import

struct Agent {
    let agentNo: Int
    let name: String
    let location: String
    let title: String
    let imageSrc: String
    let background: String
    let summaryDesc: String
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
    let content: String?
    let content2: String?
    let createdAt: Date?
    
    var isUser: Bool {
        return role == "user"
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

struct AgentView: View {
    let conversationId: Int?
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var input: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var conversation: [Message] = []
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var currentConversationId: Int?
    @State private var currentQandaId: Int = 0

    let agent = Agent(
        agentNo: 3,
        name: "Sophia Laurent",
        location: "Paris",
        title: "Interior Designer",
        imageSrc: "https://storage.googleapis.com/subgroup-images/77b4c6eb-2df5-42a5-8202-a57ceb0ec2b1.jpg?timestamp=1715842580622",
        background: "Sophia Laurent, 32, a distinguished interior designer based in Paris. With a masters degree from École Camondo, she has an exquisite blend of classical European design education and a bold, avant-garde approach.",
        summaryDesc: "Paris-based interior designer, blending classical European education from École Camondo with avant-garde design.",
        questions: []  // Removed the questions
    )
    
    init(conversationId: Int? = nil) {
        self.conversationId = conversationId
        self._currentConversationId = State(initialValue: conversationId)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        // Agent Info
                        HStack(alignment: .center, spacing: 16) {
                            AsyncImage(url: URL(string: agent.imageSrc)) { image in
                                image.resizable()
                            } placeholder: {
                                Color.customGold
                            }
                            .frame(width: conversation.isEmpty ? 100 : 50, height: conversation.isEmpty ? 100 : 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(agent.name).font(conversation.isEmpty ? .title : .headline).foregroundColor(.customDark)
                                if conversation.isEmpty {
                                    Text(agent.title).font(.headline).foregroundColor(.customTeal)
                                    Text(agent.location).font(.subheadline).foregroundColor(.customGray)
                                    Text(agent.summaryDesc).font(.body).foregroundColor(.customGray).padding(.top, 8)
                                }
                            }
                        }
                        
                        // Chat Conversation
                        ForEach(conversation) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                }
                                Text(message.content ?? "")
                                    .foregroundColor(.customDark)
                                    .padding()
                                    .background(message.isUser ? Color.customNavy.opacity(0.05) : Color.customTeal.opacity(0.05))
                                    .cornerRadius(12)
                                if !message.isUser {
                                    Spacer()
                                }
                            }
                            .id(message.id)
                        }

                        // Initial Input Field (only shown when conversation is empty)
                        if conversation.isEmpty {
                            VStack(spacing: 24) {
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $input)
                                        .frame(height: 120)
                                        .padding(0)
                                        .background(Color.clear)
                                        .focused($isInputFocused)

                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.customTeal, lineWidth: 2)
                                        .frame(height: 120)

                                    if input.isEmpty && !isInputFocused {
                                        Text("Ask Sophia interior...")
                                            .foregroundColor(.customGray.opacity(0.6))
                                            .padding(.horizontal, 16)
                                            .padding(.top, 16)
                                    }
                                    
                                    HStack {
                                        Button(action: {
                                            // Add image upload action here
                                        }) {
                                            Image(systemName: "photo")
                                                .foregroundColor(.customTeal)
                                                .font(.system(size: 20))
                                        }
                                        
                                        Spacer()
                                        
                                        Button(action: handleSubmit) {
                                            Image(systemName: "arrow.up")
                                                .foregroundColor(.customWhite)
                                                .font(.system(size: 20))
                                                .frame(width: 40, height: 40)
                                                .background(Color.customTeal)
                                                .clipShape(Circle())
                                        }
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                                }
                                .frame(height: 120)
                            }
                            .padding(.top, 32)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    scrollProxy = proxy
                    if let id = conversationId {
                        loadExistingConversation(id: id)
                    }
                }
            }
            
            // Compact Input Field at bottom (only shown when conversation is not empty)
            if !conversation.isEmpty {
                HStack {
                    ZStack(alignment: .leading) {
                        TextField("Ask follow-up...", text: $input)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .padding(.leading, 40)
                            .padding(.trailing, 40)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.customWhite)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color.customTeal, lineWidth: 1)
                                    )
                            )
                        
                        HStack {
                            Button(action: {
                                // Add image upload action here
                            }) {
                                Image(systemName: "photo")
                                    .foregroundColor(.customTeal)
                                    .font(.system(size: 20))
                            }
                            
                            Spacer()
                            
                            Button(action: handleSubmit) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .foregroundColor(.customTeal)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding()
                .background(Color.customWhite)
            }
        }
        .background(Color.customWhite)
        .onTapGesture {
            isInputFocused = false
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
    }
    
    func handleSubmit() {
        guard !input.isEmpty else { return }
        
        Task {
            do {
                guard let userId = authViewModel.userId else {
                    throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID is not available"])
                }
                
                if currentConversationId == nil {
                    currentConversationId = try await SupabaseManager.shared.startNewConversation(for: agent.agentNo, userId: userId)
                    currentQandaId = 0
                }
                
                guard let conversationId = currentConversationId else {
                    throw NSError(domain: "ConversationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get conversation ID"])
                }
                
                currentQandaId += 1
                
                // Save user's question
                try await SupabaseManager.shared.saveMessage(
                    userId: userId,
                    agentId: agent.agentNo,
                    conversationId: conversationId,
                    qandaId: currentQandaId,
                    role: "user",
                    content: input,
                    part: 1  // Added part parameter
                )
                
                // Add user's question to the conversation
                let userMessage = Message(id: UUID(), userId: authViewModel.userId, agentId: agent.agentNo, conversationId: conversationId, urlId: nil, qandaId: currentQandaId, part: 1, role: "user", content: input, content2: nil, createdAt: Date())
                conversation.append(userMessage)
                
                // Simulate AI response (replace with actual AI integration later)
                let aiResponse = "Thank you for your question. Here's a simulated response to: \(input)"
                
                // Save AI's response
                try await SupabaseManager.shared.saveMessage(
                    userId: userId,
                    agentId: agent.agentNo,
                    conversationId: conversationId,
                    qandaId: currentQandaId,
                    role: "assistant",
                    content: aiResponse,
                    part: 1  // Added part parameter
                )
                
                // Add AI's response to the conversation
                let aiMessage = Message(id: UUID(), userId: nil, agentId: agent.agentNo, conversationId: conversationId, urlId: nil, qandaId: currentQandaId, part: 1, role: "assistant", content: aiResponse, content2: nil, createdAt: Date())
                conversation.append(aiMessage)
                
                // Clear input field
                input = ""
                
                // Scroll to the bottom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scrollProxy?.scrollTo(aiMessage.id, anchor: .bottom)
                    }
                }
            } catch {
                print("Error handling submit: \(error.localizedDescription)")
                showError = true
                errorMessage = "Failed to send message. Please try again."
            }
        }
    }
    
    private func loadExistingConversation(id: Int) {
        Task {
            do {
                print("Starting to load conversation with ID: \(id)")
                guard let userId = authViewModel.userId else {
                    print("User ID is not available")
                    throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID is not available"])
                }
                print("User ID: \(userId)")
                
                let messages = try await SupabaseManager.shared.fetchMessages(for: id)
                print("Fetched \(messages.count) messages")
                currentConversationId = id
                conversation = messages
                
                // Scroll to the bottom of the conversation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scrollProxy?.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            } catch {
                print("Error loading conversation: \(error)")
                
                showError = true
                errorMessage = "Failed to load conversation: \(error.localizedDescription)"
            }
        }
    }
}

struct AgentView_Previews: PreviewProvider {
    static var previews: some View {
        AgentView()
            .environmentObject(mockAuthViewModel())
    }
    
    static func mockAuthViewModel() -> AuthViewModel {
        let mockSupabase = SupabaseClient(supabaseURL: URL(string: "https://example.com")!, supabaseKey: "dummy-key")
        let authViewModel = AuthViewModel(supabase: mockSupabase)
        authViewModel.userId = UUID() // Provide a mock UUID
        return authViewModel
    }
}

