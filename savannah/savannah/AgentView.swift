//
//  AgentView.swift
//  savannah
//
//  Created by Kemal Erol on 11/09/2024.
//
 
import SwiftUI
import Supabase  // Add this import
import Combine

struct AgentView: View {
    let conversationId: Int?
    let agentNo: Int
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var input: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var conversation: [Message] = []
    @State private var scrollProxy: ScrollViewProxy?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var currentConversationId: Int?
    @State private var currentQandaId: Int = 0
    @State private var selectedImage: UIImage?
    @State private var imageUrl: String?
    @State private var isImagePickerPresented = false
    @State private var thumbnailImage: UIImage?
    @State private var cancellables: Set<AnyCancellable> = []
    
    @State private var agent: Agent?
    @State private var isLoading = true
    @Environment(\.presentationMode) var presentationMode
    var isFromDiscover: Bool
    
    init(conversationId: Int? = nil, agentNo: Int, isFromDiscover: Bool = false) {
        self.conversationId = conversationId
        self.agentNo = agentNo
        self.isFromDiscover = isFromDiscover
        self._currentConversationId = State(initialValue: conversationId)
        print("AgentView initialized with agentNo: \(agentNo)")
    }

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading agent data...")
            } else if let agent = agent {
                ZStack(alignment: .bottom) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 24) {
                                // Agent Info
                                HStack(alignment: .center, spacing: 16) {
                                    AsyncImage(url: URL(string: agent.imageUrl)) { image in
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
                                    VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                                        if message.isUser {
                                            if message.isImage, let imageUrl = message.content {
                                                AsyncImage(url: URL(string: imageUrl)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(maxWidth: 200, maxHeight: 200)
                                                        .cornerRadius(12)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                            } else {
                                                Text(message.content ?? "")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.customDark)
                                                    .padding()
                                                    .background(Color.customNavy.opacity(0.05))
                                                    .cornerRadius(12)
                                            }
                                        } else {
                                            CustomMarkdownRenderer(content: message.content ?? "")
                                                .padding()
                                                .background(Color.customTeal.opacity(0.05))
                                                .cornerRadius(12)
                                                .frame(maxWidth: 300, alignment: .leading)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
                                    .id(message.id)
                                }

                                // Initial Input Field (only shown when conversation is empty)
                                if conversation.isEmpty {
                                    InitialInputView(
                                        input: $input,
                                        imageUrl: $imageUrl,
                                        thumbnailImage: $thumbnailImage,
                                        agent: agent,
                                        isInputFocused: $isInputFocused,
                                        handleSubmit: handleSubmit,
                                        presentImagePicker: presentImagePicker,
                                        removeImage: removeImage
                                    )
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
                                    .focused($isInputFocused)

                                if let thumbnail = thumbnailImage {
                                    ZStack(alignment: .topLeading) {
                                        Image(uiImage: thumbnail)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 40, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        
                                        Button(action: removeImage) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.customTeal)
                                                .background(Color.white)
                                                .clipShape(Circle())
                                        }
                                        .offset(x: -6, y: -6)
                                    }
                                    .offset(x: 8, y: -20)
                                }
                                
                                HStack {
                                    Button(action: presentImagePicker) {
                                        Image(systemName: thumbnailImage != nil ? "photo.fill" : "photo")
                                            .foregroundColor(thumbnailImage != nil ? .customTeal : .customGray)
                                            .font(.system(size: 20))
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: handleSubmit) {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .foregroundColor(.customTeal)
                                            .font(.system(size: 24))
                                    }
                                }
                                .frame(maxWidth: .infinity)
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
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(selectedImage: $selectedImage)
                }
                .onChange(of: selectedImage) { oldImage, newImage in
                    if let image = newImage {
                        if let optimizedImage = optimizeImage(image) {
                            uploadImage(optimizedImage)
                        } else {
                            print("Failed to optimize image")
                        }
                    }
                }
                // Only show custom back button if opened from DiscoverView
                .if(isFromDiscover) { view in
                    view.navigationBarItems(leading: Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                    })
                }
            } else {
                Text("Agent not found")
            }
        }
        .onAppear {
            loadAgentDataIfNeeded()
        }
    }
    
    private func loadAgentDataIfNeeded() {
        guard agent == nil else { return }
        print("AgentView appeared for agentNo: \(agentNo)")
        isLoading = true
        DispatchQueue.main.async {
            self.agent = AgentList.getAgent(by: self.agentNo)
            self.isLoading = false
            print("Agent data loaded: \(self.agent?.name ?? "Not found")")
        }
    }
    
    func handleSubmit() {
        Task {
            do {
                guard let userId = authViewModel.userId else {
                    throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User ID is not available"])
                }
                
                if currentConversationId == nil {
                    currentConversationId = try await SupabaseManager.shared.startNewConversation(for: agent?.agentNo ?? 0, userId: userId)
                    currentQandaId = 0
                }
                
                guard let conversationId = currentConversationId else {
                    throw NSError(domain: "ConversationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get conversation ID"])
                }
                
                currentQandaId += 1
                
                // Add user's text message to conversation immediately
                if !input.isEmpty {
                    let userMessage = Message(id: UUID(), userId: authViewModel.userId, agentId: agent?.agentNo ?? 0, conversationId: conversationId, urlId: nil, qandaId: currentQandaId, part: 1, role: "user", content: input, content2: nil, createdAt: Date())
                    await MainActor.run {
                        conversation.append(userMessage)
                    }
                }
                
                // Add user's image message to conversation immediately
                if let imageUrl = imageUrl {
                    let imageMessage = Message(id: UUID(), userId: authViewModel.userId, agentId: agent?.agentNo ?? 0, conversationId: conversationId, urlId: nil, qandaId: currentQandaId, part: 1, role: "user-image", content: imageUrl, content2: nil, createdAt: Date())
                    await MainActor.run {
                        conversation.append(imageMessage)
                    }
                }
                
                // Prepare conversation for OpenAI
                let messages = prepareConversationForOpenAI()
                
                // Create a placeholder message for the AI response
                let aiMessageId = UUID()
                let aiMessage = Message(id: aiMessageId, userId: nil, agentId: agent?.agentNo ?? 0, conversationId: conversationId, urlId: nil, qandaId: currentQandaId, part: 1, role: "assistant", content: "", content2: nil, createdAt: Date())
                
                await MainActor.run {
                    conversation.append(aiMessage)
                    
                    // Scroll to the bottom
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            scrollProxy?.scrollTo(aiMessageId, anchor: .bottom)
                        }
                    }
                }
                
                // Send request to OpenAI and update AI response
                var aiResponse = ""
                do {
                    let stream = try await OpenAIManager.shared.sendStreamRequest(messages: messages)
                    for try await streamContent in stream {
                        aiResponse += streamContent
                        await MainActor.run {
                            if let index = conversation.firstIndex(where: { $0.id == aiMessageId }) {
                                conversation[index].content = aiResponse
                            }
                        }
                    }
                } catch {
                    throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get AI response: \(error.localizedDescription)"])
                }
                
                // Save messages to database
                if !input.isEmpty {
                    try await SupabaseManager.shared.saveMessage(
                        userId: userId,
                        agentId: agent?.agentNo ?? 0,
                        conversationId: conversationId,
                        qandaId: currentQandaId,
                        role: "user",
                        content: input,
                        part: 1
                    )
                }
                
                if let imageUrl = imageUrl {
                    try await SupabaseManager.shared.saveMessage(
                        userId: userId,
                        agentId: agent?.agentNo ?? 0,
                        conversationId: conversationId,
                        qandaId: currentQandaId,
                        role: "user-image",
                        content: imageUrl,
                        part: 1
                    )
                }
                
                try await SupabaseManager.shared.saveMessage(
                    userId: userId,
                    agentId: agent?.agentNo ?? 0,
                    conversationId: conversationId,
                    qandaId: currentQandaId,
                    role: "assistant",
                    content: aiResponse,
                    part: 1
                )
                
                // Clear input field, image URL, and thumbnail
                await MainActor.run {
                    input = ""
                    imageUrl = nil
                    thumbnailImage = nil
                }
                
            } catch {
                print("Error handling submit: \(error.localizedDescription)")
                await MainActor.run {
                    showError = true
                    errorMessage = "Failed to send message. Please try again."
                }
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
                
                let messages = try await SupabaseManager.shared.fetchMessages(for: id, agentId: agentNo, userId: userId)
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

extension AgentView {
    private func presentImagePicker() {
        isImagePickerPresented = true
    }

    private func optimizeImage(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: 800, height: 800)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        Task {
            do {
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    print("Failed to convert image to data")
                    return
                }
                
                let url = try await GoogleCloudStorageManager.shared.uploadImage(imageData)
                await MainActor.run {
                    self.imageUrl = url
                    self.thumbnailImage = image // Set the thumbnail image
                    print("Image uploaded successfully. URL: \(url)")
                }
            } catch {
                await MainActor.run {
                    print("Failed to upload image: \(error.localizedDescription)")
                    self.showError = true
                    self.errorMessage = "Failed to upload image. Please try again."
                }
            }
        }
    }
    
    private func extractImageUrl(from content: String) -> String? {
        let pattern = "\\[Image: (.*?)\\]"
        if let range = content.range(of: pattern, options: .regularExpression) {
            let extracted = content[range]
            let url = String(extracted.dropFirst(8).dropLast(1))
            return url
        }
        return nil
    }
    
    private func extractTextContent(from content: String) -> String {
        return content.replacingOccurrences(of: "\\[Image: .*?\\]", with: "", options: .regularExpression)
    }
    
    private func removeImage() {
        self.imageUrl = nil
        self.thumbnailImage = nil
    }
    
    private func prepareConversationForOpenAI() -> [ChatGPTMessage] {
        var messages: [ChatGPTMessage] = []
        
        // Add system message with agent's background
        messages.append(ChatGPTMessage(role: "system", content: .text("\(agent?.name ?? ""), \(agent?.description ?? "")")))
        
        // Add conversation history
        for (index, message) in conversation.enumerated() {
            switch message.role {
            case "user":
                if let nextMessage = conversation.indices.contains(index + 1) ? conversation[index + 1] : nil,
                   nextMessage.role == "user-image" {
                    // If the next message is an image, combine text and image
                    let imageUrl = nextMessage.content ?? ""
                    let content: [ChatGPTMessage.ContentPart] = [
                        ChatGPTMessage.ContentPart(type: "text", text: message.content, image_url: nil),
                        ChatGPTMessage.ContentPart(type: "image_url", text: nil, image_url: ChatGPTMessage.ContentPart.ImageURL(url: imageUrl))
                    ]
                    messages.append(ChatGPTMessage(role: "user", content: .multipart(content)))
                } else {
                    // If there's no image, just add the text
                    messages.append(ChatGPTMessage(role: "user", content: .text(message.content ?? "")))
                }
            case "user-image":
                // Skip this case as we handle it in the "user" case
                break
            case "assistant":
                messages.append(ChatGPTMessage(role: "assistant", content: .text(message.content ?? "")))
            default:
                break // Ignore any other roles
            }
        }
        
        // Print the prepared messages for debugging
        print("Prepared messages for OpenAI:")
        for (index, message) in messages.enumerated() {
            print("[\(index)] Role: \(message.role), Content: \(message.content)")
        }
        
        return messages
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AgentView_Previews: PreviewProvider {
    static var previews: some View {
        AgentView(agentNo: 1)
            .environmentObject(mockAuthViewModel())
    }
    
    static func mockAuthViewModel() -> AuthViewModel {
        let mockSupabase = SupabaseClient(supabaseURL: URL(string: "https://example.com")!, supabaseKey: "dummy-key")
        let authViewModel = AuthViewModel(supabase: mockSupabase)
        authViewModel.userId = UUID() // Provide a mock UUID
        return authViewModel
    }
}

// Add this extension to support the .if modifier
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}