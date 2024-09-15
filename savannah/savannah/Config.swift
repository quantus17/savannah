//
//  Config.swift
//  savannah
//
//  Created by Kemal Erol on 14/09/2024.
//

import Foundation

struct Config {
    static let supabaseURL = URL(string: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "")!
    static let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? ""
    static let openAIAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
}

