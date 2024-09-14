//AuthView.swift
import SwiftUI
import Supabase

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingEmailSentMessage = false
    @Published var userId: UUID?
    
    let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
        checkAuth()
    }
    
    func checkAuth() {
        Task {
            do {
                let session = try await supabase.auth.session
                await MainActor.run {
                    isAuthenticated = !session.accessToken.isEmpty
                    userId = session.user.id
                    email = session.user.email ?? ""
                }
            } catch {
                print("Error checking auth: \(error)")
                await MainActor.run {
                    isAuthenticated = false
                    userId = nil
                    email = ""
                }
            }
        }
    }
    
    func signInWithEmail() {
        isLoading = true
        errorMessage = nil
        showingEmailSentMessage = false
        Task {
            do {
                try await supabase.auth.signInWithOTP(email: email)
                await MainActor.run {
                    isLoading = false
                    showingEmailSentMessage = true
                    print("Magic link sent to: \(email)")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error sending magic link: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func handleMagicLink(url: URL) {
        guard let accessToken = url.queryParameters?["access_token"],
              let refreshToken = url.queryParameters?["refresh_token"] else {
            errorMessage = "Invalid magic link"
            return
        }
        
        Task {
            do {
                try await supabase.auth.setSession(accessToken: accessToken, refreshToken: refreshToken)
                await MainActor.run {
                    isAuthenticated = true
                    checkAuth() // This will update the isAuthenticated state
                    print("Authentication successful")
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error authenticating: \(error.localizedDescription)"
                    print("Authentication error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleAuthCode(_ code: String) {
        Task {
            do {
                let session = try await supabase.auth.exchangeCodeForSession(authCode: code)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.userId = session.user.id
                    self.email = session.user.email ?? ""
                    print("Authentication successful. User ID: \(self.userId?.uuidString ?? "nil")")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error authenticating: \(error.localizedDescription)"
                    print("Authentication error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Comment out the entire temporary method
    
   func setAuthenticationForTesting(_ value: Bool) {
        DispatchQueue.main.async {
            self.isAuthenticated = value
            if value {
                self.userId = UUID(uuidString: "d65a85fa-f141-47eb-9f94-f21005365c88")
                self.email = "test@example.com"
            } else {
                self.userId = nil
                self.email = ""
            }
            print("Authentication set to: \(value)")
            print("Test User ID set to: \(self.userId?.uuidString ?? "nil")")
        }
    }
    
    
}

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Welcome to Savannah")
                    .customFont(.title)
                    .foregroundColor(.customTeal)
                    .padding(.top, 50)
                
                TextField("Email", text: $viewModel.email)
                    .padding(.horizontal, 12)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.customTeal, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Button(action: viewModel.signInWithEmail) {
                    Text("Send Magic Link")
                        .customFont(.headline)
                        .foregroundColor(.customWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.customTeal)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Button(action: signInWithGoogle) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                    }
                    .customFont(.subheadline)
                    .foregroundColor(.customTeal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.customTeal, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Button(action: signInWithApple) {
                    HStack {
                        Image("apple_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Apple")
                    }
                    .customFont(.subheadline)
                    .foregroundColor(.customTeal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.customTeal, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
                
                if viewModel.showingEmailSentMessage {
                    Text("Check your email for the magic link!")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .padding()
        }
        .background(Color.customWhite)
        #if compiler(>=5.9) && canImport(SwiftUI)
        .onChange(of: viewModel.isAuthenticated) { oldValue, newValue in
            if newValue {
                dismiss()
            }
        }
        #else
        .onChange(of: viewModel.isAuthenticated) { newValue in
            if newValue {
                dismiss()
            }
        }
        #endif
    }

    func signInWithGoogle() {
        // Implement Google Sign-In
        print("Signing in with Google")
    }

    func signInWithApple() {
        // Implement Apple Sign-In
        print("Signing in with Apple")
    }
}

// Helper extension to parse URL parameters
extension URL {
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel(supabase: SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseKey
        )))
}
