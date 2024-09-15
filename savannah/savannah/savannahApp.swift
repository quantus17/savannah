//
//  savannahApp.swift
//  savannah
//
//  Created by Kemal Erol on 07/09/2024.
//

import SwiftUI
import Supabase

@main
struct SavannahApp: App {
    init() {
        // Set environment variables programmatically
        setenv("SUPABASE_URL", "https://lkrjdardmdlarzkmviwp.supabase.co", 1)
        setenv("SUPABASE_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrcmpkYXJkbWRsYXJ6a212aXdwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU4MDI4OTYsImV4cCI6MjA0MTM3ODg5Nn0.Hcub0wJubR5GbRap0QSWD_1-A2_29tIDrCn5yk0CDKc", 1)
        
        // Print the environment variables to verify they're set
        print("SUPABASE_URL set to: \(ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "not set")")
        print("SUPABASE_KEY set to: \(ProcessInfo.processInfo.environment["SUPABASE_KEY"] ?? "not set")")
    }

    var body: some Scene {
        WindowGroup {
            AppContentView()
        }
    }
}

struct AppContentView: View {
    @StateObject private var authViewModel: AuthViewModel
    
    init() {
        let supabaseURLString = ProcessInfo.processInfo.environment["SUPABASE_URL"]
        let supabaseURL = supabaseURLString.flatMap { URL(string: $0) }
        let supabaseKey = ProcessInfo.processInfo.environment["SUPABASE_KEY"]
        
        let supabaseClient: SupabaseClient?
        if let supabaseURL = supabaseURL, let supabaseKey = supabaseKey {
            supabaseClient = SupabaseClient(
                supabaseURL: supabaseURL,
                supabaseKey: supabaseKey
            )
        } else {
            supabaseClient = nil
            print("Warning: Supabase environment variables are not set properly")
        }
        
        _authViewModel = StateObject(wrappedValue: AuthViewModel(supabase: supabaseClient))
    }
    
    var body: some View {
        Group {
            if !authViewModel.isSupabaseInitialized {
                Text("Supabase environment variables are not set properly")
                    .foregroundColor(.red)
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                HomePage(authViewModel: authViewModel)
            }
        }
        .environmentObject(authViewModel)
        .onOpenURL { url in
            // Check if the URL contains a code parameter
            if let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "code" })?.value {
                authViewModel.handleAuthCode(code)
            }
        }
        .onAppear {
            // set below code commented to go production
           // authViewModel.setAuthenticationForTesting(true)
            print("Initial auth state: \(authViewModel.isAuthenticated)")
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            AgentView(agentNo: 3) // You can change this to any default agent number
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            ThreadsView()
                .tabItem {
                    Label("Threads", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(1)
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
                .tag(3)
        }
    }
}
