/*import SwiftUI
import Supabase

struct BottomMenuView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: { selectedTab = 0 }) {
                VStack {
                    Image(systemName: "house")
                    Text("Home")
                }
            }
            .foregroundColor(selectedTab == 0 ? .customTeal : .customGray)
            
            Spacer()
            
            Button(action: { selectedTab = 1 }) {
                VStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Threads")
                }
            }
            .foregroundColor(selectedTab == 1 ? .customTeal : .customGray)
            
            Spacer()
            
            Button(action: { selectedTab = 2 }) {
                VStack {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
            }
            .foregroundColor(selectedTab == 2 ? .customTeal : .customGray)
            
            Spacer()
            
            Button(action: { selectedTab = 3 }) {
                VStack {
                    Image(systemName: "person.circle")
                    Text("Account")
                }
            }
            .foregroundColor(selectedTab == 3 ? .customTeal : .customGray)
            
            Spacer()
        }
        .padding(.top, 10)
        .background(Color.customWhite)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.customGray.opacity(0.2)),
            alignment: .top
        )
    }
}

// Preview
struct BottomMenuView_Previews: PreviewProvider {
    static var previews: some View {
        BottomMenuView(selectedTab: .constant(0))
            .environmentObject(AuthViewModel(supabase: SupabaseClient(
                supabaseURL: URL(string: "https://example.com")!,
                supabaseKey: "dummy-key"
            )))
    }
}
*/