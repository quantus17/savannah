//
//  HomePage.swift
//  savannah
//
//  Created by Kemal Erol on 08/09/2024.
//

import SwiftUI
import Supabase  // Add this import

struct HomePage: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showAuthView = false

    var body: some View {
        ZStack {
            Color.customWhite.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("Welcome to Savannah")
                    .customFont(.title)  // Changed from .largeTitle to .title
                    .foregroundColor(.customDark)
                
                // App icon image with rounded corners
                Image("homePage") // Using the new image set we created
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(20) // Adjust this value to change the roundness of corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.customWhite, lineWidth: 1)
                    )
                
                Text("Your AI-powered interior design companion")
                    .customFont(.headline)
                    .foregroundColor(.customGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    print("Get Started pressed, auth state: \(authViewModel.isAuthenticated)")
                    if authViewModel.isAuthenticated {
                        // If already authenticated, do nothing (MainTabView will be shown)
                        print("User is authenticated, should show MainTabView")
                    } else {
                        showAuthView = true
                        print("Showing AuthView")
                    }
                }) {
                    Text("Get Started")
                        .customFont(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.customWhite)
                        .frame(width: 200)
                        .padding()
                        .background(Color.customTeal)
                        .cornerRadius(10)
                }
            }
        }
        .fullScreenCover(isPresented: $showAuthView) {
            AuthView()
                .environmentObject(authViewModel)
        }
        .onAppear {
            print("HomePage appeared, auth state: \(authViewModel.isAuthenticated)")
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(authViewModel: AuthViewModel(supabase: SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseKey
        )))
    }
}
