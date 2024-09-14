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
    var body: some Scene {
        WindowGroup {
            AppContentView()
        }
    }
}

struct AppContentView: View {
    @StateObject private var authViewModel = AuthViewModel(supabase: SupabaseClient(
        supabaseURL: Config.supabaseURL,
        supabaseKey: Config.supabaseKey
    ))
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
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
            authViewModel.setAuthenticationForTesting(true)
            print("Initial auth state: \(authViewModel.isAuthenticated)")
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            AgentView()
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
