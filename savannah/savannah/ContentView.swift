//
//  ContentView.swift
//  Savannah2
//
//  Created by Kemal Erol on 06/09/2024.
//

import SwiftUI

struct Agent {
    let agentNo: Int
    let name: String
    let location: String
    let title: String
    let imageSrc: String
    let background: String
    let summaryDesc: String
    let questions: [String]
}

struct ContentView: View {
    let agent = Agent(
        agentNo: 3,
        name: "Sophia Laurent",
        location: "Paris",
        title: "Interior Designer",
        imageSrc: "https://storage.googleapis.com/subgroup-images/77b4c6eb-2df5-42a5-8202-a57ceb0ec2b1.jpg?timestamp=1715842580622",
        background: "Sophia Laurent, 32, a distinguished interior designer based in Paris. With a masters degree from École Camondo, she has an exquisite blend of classical European design education and a bold, avant-garde approach.",
        summaryDesc: "Paris-based interior designer, blending classical European education from École Camondo with avant-garde design.",
        questions: [
            "Bonjour! I'm Sophia Laurent, the Parisian muse of interiors. Let's embark on a chic design journey—where classic elegance meets avant-garde flair. Ready to transform your space? 💫",
            "🎨 Favorite color palettes this season?"
        ]
    )
    
    @State private var input: String = ""
    @State private var conversationHistory: [(role: String, content: String)] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Agent Info
                HStack(alignment: .top, spacing: 16) {
                    AsyncImage(url: URL(string: agent.imageSrc)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(agent.name).font(.title).fontWeight(.bold)
                        Text(agent.title).font(.headline).foregroundColor(.secondary)
                        Text(agent.location).font(.subheadline).foregroundColor(.gray)
                        Text(agent.summaryDesc).font(.body).padding(.top, 8)
                    }
                }
                
                // Input Field
                TextEditor(text: $input)
                    .frame(height: 100)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .overlay(
                        Text("Ask Sophia about interior design...")
                            .foregroundColor(.gray)
                            .opacity(input.isEmpty ? 1 : 0)
                            .padding(8),
                        alignment: .topLeading
                    )
                
                // Submit Button
                Button(action: handleSubmit) {
                    Text("Submit")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(8)
                }
                
                // Suggested Questions
                ForEach(agent.questions, id: \.self) { question in
                    Button(action: { input = question }) {
                        Text(question)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))  // Updated this line
                            .cornerRadius(8)
                    }
                }
                
                // Conversation history can be added here later
            }
            .padding()
        }
    }
    
    func handleSubmit() {
        print("Submitted:", input)
        conversationHistory.append((role: "user", content: input))
        input = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
