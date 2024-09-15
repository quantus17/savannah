//
//  GoogleCloudStorageManager.swift
//  savannah
//
//  Created by Kemal Erol on 12/09/2024.
//

import Foundation

class GoogleCloudStorageManager {
    static let shared = GoogleCloudStorageManager()
    private let uploadURL = URL(string: "https://fiain.ai/api/upload-mobile-image")!
    
    private init() {}
    
    func uploadImage(_ imageData: Data) async throws -> String {
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "ServerError", code: 0, userInfo: nil)
        }
        
        let jsonResult = try JSONDecoder().decode(UploadResponse.self, from: data)
        return jsonResult.publicUrl
    }
}

struct UploadResponse: Codable {
    let publicUrl: String
}
