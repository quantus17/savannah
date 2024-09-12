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
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/77b4c6eb-2df5-42a5-8202-a57ceb0ec2b1.jpg?timestamp=1715842580622",
                        title: "Design with Sophia",
                        description: "Bold, Edgy Parisian Chic for the Modern Home",
                        action: { navigateToSophia = true }
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/02890053-84ab-4c0d-8c40-201bd0712fd2.jpg",
                        title: "Design with Freja",
                        description: "Scandinavian Simplicity for a Serene Home"
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/b19023f1-a857-4a66-ad3f-b52d381079f8.jpg?timestamp=1721548645776",
                        title: "Style with Liam",
                        description: "Street-Chic Fusion for the Urban Trendsetter"
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/8c317d2a-dec0-4852-a1b8-4b2faf3d56a2.jpg",
                        title: "Style with Chloe",
                        description: "Daring, Eclectic Fashion for the Modern Trendsetter"
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/de6a9a75-f962-4e00-ad17-21d6ed153c85.jpg",
                        title: "Room Reimaginer",
                        description: "Transform your space with a snap"
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/8fac0ba3-d6fc-4a37-9a2c-5ddbfaa05ac3.jpg?timestamp=1721540656031",
                        title: "Outfit Ideas",
                        description: "Discover Your Stylish Looks"
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/6e5fe43d-999f-4cbe-80e4-5127d6ebd883.jpg",
                        title: "Brand Match",
                        description: "Get Brand Advice for Every Purchase"
                    )
                    
                    DiscoverCard(
                        imageUrl: "https://storage.googleapis.com/subgroup-images/7d5003d3-e526-48d9-abfc-a10607fe71e1.jpg",
                        title: "Essential Wardrobe",
                        description: "Curate Your Perfect Capsule"
                    )
                }
            }
            .padding()
        }
        .sheet(isPresented: $navigateToSophia) {
            AgentView()
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
