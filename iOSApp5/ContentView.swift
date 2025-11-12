import SwiftUI

struct ContentView: View {
    // MARK: - Stored Properties
    
    // Persistent user setting using @AppStorage (feature 1)
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    // Used for Alert presentation (feature 2)
    @State private var showAlert = false
    
    // Controls animation state (feature 3)
    @State private var rotationAngle = 0.0
    
    // Controls search filter (feature 4)
    @State private var searchText = ""
    
    // Sample data for List
    let techTopics = [
        "SwiftUI",
        "Combine",
        "Firebase",
        "CoreData",
        "Animation",
        "Concurrency",
        "AppStorage",
        "NavigationStack"
    ]
    
    // MARK: - Computed Property
    // Filters list items based on search text
    var filteredTopics: [String] {
        if searchText.isEmpty {
            return techTopics
        } else {
            return techTopics.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // MARK: - Toggle for Dark Mode Preference (Feature 1)
                Toggle("Dark Mode", isOn: $darkModeEnabled)
                    .padding(.horizontal)
                
                // MARK: - Animated AsyncImage (Feature 2 + 3)
                AsyncImage(url: URL(string: "https://picsum.photos/250"))
                { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .rotationEffect(.degrees(rotationAngle))
                            .onTapGesture {
                                // Rotates image 45 degrees with animation each tap
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    rotationAngle += 45
                                }
                            }
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .foregroundColor(.gray)
                    case .empty:
                        ProgressView() // loading indicator
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // MARK: - Alert Example (Feature 4)
                Button("Show Info Alert") {
                    showAlert = true
                }
                .alert("SwiftUI Cookbook Example", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("This demo shows multiple SwiftUI features combined in one app.")
                }
                .buttonStyle(.borderedProminent)
                
                // MARK: - List with Sections and Search (Feature 5 + 6)
                List {
                    Section(header: Text("Learning Topics")) {
                        ForEach(filteredTopics, id: \.self) { topic in
                            NavigationLink(destination: DetailView(topic: topic)) {
                                Text(topic)
                            }
                        }
                    }
                    
                    Section(header: Text("App Settings")) {
                        HStack {
                            Text("Dark Mode")
                            Spacer()
                            Image(systemName: darkModeEnabled ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(darkModeEnabled ? .yellow : .orange)
                        }
                    }
                }
                // searchable modifier (Feature 7)
                .searchable(text: $searchText, prompt: "Search topics")
            }
            .navigationTitle("iOSApp5 Demo App")
            .padding(.bottom)
        }
        // Apply dark mode dynamically based on toggle
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

//
//  DetailView.swift
//  Displays information about the selected topic
//

struct DetailView: View {
    var topic: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text(topic)
                .font(.largeTitle)
                .bold()
            Text("Details for \(topic)")
                .font(.title3)
                .foregroundColor(.secondary)
            
            AsyncImage(url: URL(string: "https://picsum.photos/300"))
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle(topic)
    }
}

//
// MARK: - Preview
//

