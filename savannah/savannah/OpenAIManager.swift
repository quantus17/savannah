//
//  OpenAIManager.swift
//  savannah
//
//  Created by Kemal Erol on 13/09/2024.
//
import Foundation

enum OpenAIError: Error {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError
}

class OpenAIManager {
    static let shared = OpenAIManager()
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("OpenAI API key environment variable is not set")
        }
        self.apiKey = apiKey
    }
    
    func sendStreamRequest(messages: [ChatGPTMessage]) async throws -> AsyncThrowingStream<String, Error> {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages.map { $0.dictionary },
            "stream": true
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // Create a copy of the request to use inside the closure
        let requestCopy = request
        
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let (bytes, response) = try await URLSession.shared.bytes(for: requestCopy)
                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw OpenAIError.invalidResponse
                    }
                    guard 200...299 ~= httpResponse.statusCode else {
                        throw OpenAIError.apiError("Status code: \(httpResponse.statusCode)")
                    }
                    
                    var buffer = Data()
                    for try await byte in bytes {
                        buffer.append(byte)
                        if byte == UInt8(ascii: "\n") {
                            if let line = String(data: buffer, encoding: .utf8) {
                                if line.hasPrefix("data: "),
                                   let data = line.dropFirst(6).data(using: .utf8),
                                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                   let choices = json["choices"] as? [[String: Any]],
                                   let delta = choices.first?["delta"] as? [String: Any],
                                   let content = delta["content"] as? String {
                                    continuation.yield(content)
                                }
                            }
                            buffer.removeAll()
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}

struct ChatGPTMessage: Codable {
    let role: String
    let content: MessageContent

    enum MessageContent: Codable {
        case text(String)
        case multipart([ContentPart])

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let string = try? container.decode(String.self) {
                self = .text(string)
            } else if let array = try? container.decode([ContentPart].self) {
                self = .multipart(array)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid message content")
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .text(let string):
                try container.encode(string)
            case .multipart(let array):
                try container.encode(array)
            }
        }
    }

    struct ContentPart: Codable {
        let type: String
        let text: String?
        let image_url: ImageURL?

        struct ImageURL: Codable {
            let url: String
        }
    }

    var dictionary: [String: Any] {
        var dict: [String: Any] = ["role": role]
        switch content {
        case .text(let string):
            dict["content"] = string
        case .multipart(let array):
            dict["content"] = array.map { $0.dictionaryRepresentation }
        }
        return dict
    }
}

extension ChatGPTMessage.ContentPart {
    var dictionaryRepresentation: [String: Any] {
        var dict: [String: Any] = ["type": type]
        if let text = text {
            dict["text"] = text
        }
        if let imageUrl = image_url {
            dict["image_url"] = ["url": imageUrl.url]
        }
        return dict
    }
}

