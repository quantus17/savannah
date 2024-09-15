import SwiftUI
import Supabase
struct DiscoverView: View {
    let gridItems = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var navigateToSophia = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Discover Your Style Universe")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your Style, Your Rules")
                    .font(.title2)
                
                LazyVGrid(columns: gridItems, spacing: 16) {
                    ForEach(AgentList.agents) { agent in
                        DiscoverCard(
                            imageUrl: agent.imageUrl,
                            title: "Design with \(agent.name)",
                            description: agent.summaryDesc,
                            action: { 
                                // Update this to use the sheet or navigation you prefer
                                navigateToSophia = true
                                // You might want to use a different state variable for each agent
                                // or pass the agent.agentNo to the next view
                            }
                        )
                    }
                    
                    // Add your other static DiscoverCards here
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/de6a9a75-f962-4e00-ad17-21d6ed153c85.jpg",
                        title: "Room Reimaginer",
                        description: "Transform your space with a snap"
                    )
                    
                    // ... (other static cards)
                }
            }
            .padding()
        }
        .sheet(isPresented: $navigateToSophia) {
            // Update this to use the selected agent's number
            AgentView(agentNo: 3) // This should be dynamic based on user selection
        }
    }
}

struct DiscoverCard: View {
    let imageUrl: String
    let title: String
    let description: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(height: 150)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: { action?() }) {
                    Text("Start →")
                        .fontWeight(.bold)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                }
            }
            .padding(12)
        }
        .frame(height: 280)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

// Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
            .environmentObject(AuthViewModel(supabase: SupabaseClient(
                supabaseURL: URL(string: "https://example.com")!,
                supabaseKey: "dummy-key"
            )))
    }
}