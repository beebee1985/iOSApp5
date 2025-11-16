import SwiftUI
import Share

// MARK: - Topic Model
struct Topic: Identifiable, Codable {
    let id = UUID()
    var name: String
    var isFavorite: Bool = false
    
    enum CodingKeys: CodingKey {
        case name, isFavorite
    }
}

struct ContentView: View {
    // MARK: - Stored Properties
    
    // Persistent user setting using @AppStorage (feature 1)
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("topicsData") private var topicsData: Data = Data()
    
    // Used for Alert presentation (feature 2)
    @State private var showAlert = false
    
    // Controls animation state (feature 3)
    @State private var rotationAngle = 0.0
    
    // Controls search filter (feature 4)
    @State private var searchText = ""
    
    // Feature 1: Tab Navigation
    @State private var selectedTab = 0
    
    // Feature 2: Favoriting System
    @State private var topics: [Topic] = [
        Topic(name: "SwiftUI"),
        Topic(name: "Combine"),
        Topic(name: "Firebase"),
        Topic(name: "CoreData"),
        Topic(name: "Animation"),
        Topic(name: "Concurrency"),
        Topic(name: "AppStorage"),
        Topic(name: "NavigationStack")
    ]
    
    // Feature 3: Custom Form
    @State private var showAddTopicSheet = false
    @State private var newTopicName = ""
    
    // Feature 4: Share Button
    @State private var shareText = ""
    @State private var showShareSheet = false
    
    // MARK: - Computed Properties
    // Filters topics based on search text
    var filteredTopics: [Topic] {
        if searchText.isEmpty {
            return topics
        } else {
            return topics.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // Get favorite topics
    var favoriteTopics: [Topic] {
        topics.filter { $0.isFavorite }
    }
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: Home
            homeTab
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // MARK: - Tab 2: All Topics
            topicsTab
                .tabItem {
                    Label("Topics", systemImage: "book.fill")
                }
                .tag(1)
            
            // MARK: - Tab 3: Favorites
            favoritesTab
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(2)
            
            // MARK: - Tab 4: Settings
            settingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
        .sheet(isPresented: $showAddTopicSheet) {
            addTopicSheet
        }
    }
    
    // MARK: - Home Tab View
    private var homeTab: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.3), .purple.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // MARK: - Animated AsyncImage with Gesture
                    AsyncImage(url: URL(string: "https://picsum.photos/250"))
                    { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .rotationEffect(.degrees(rotationAngle))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                                .onTapGesture {
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
                            ProgressView()
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    // Info Alert Button
                    Button(action: { showAlert = true }) {
                        Label("Show Info Alert", systemImage: "info.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .alert("SwiftUI Features", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("This app demonstrates Tab Navigation, Favorites, Form Input, Share, Gradients, Sheets, and Haptic Feedback!")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Welcome")
        }
    }
    
    // MARK: - Topics Tab View
    private var topicsTab: some View {
        NavigationStack {
            List {
                Section(header: Text("Learning Topics")) {
                    ForEach($topics) { $topic in
                        NavigationLink(destination: DetailView(topic: $topic)) {
                            HStack {
                                Text(topic.name)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        topic.isFavorite.toggle()
                                    }
                                }) {
                                    Image(systemName: topic.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(topic.isFavorite ? .red : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search topics")
            .navigationTitle("All Topics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTopicSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
    }
    
    // MARK: - Favorites Tab View
    private var favoritesTab: some View {
        NavigationStack {
            if favoriteTopics.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No Favorites Yet")
                        .font(.headline)
                    Text("Mark topics as favorites to see them here")
                        .foregroundColor(.secondary)
                }
                .navigationTitle("Favorites")
            } else {
                List {
                    Section(header: Text("Favorite Topics")) {
                        ForEach($topics.filter { $0.isFavorite.wrappedValue }) { $topic in
                            NavigationLink(destination: DetailView(topic: $topic)) {
                                HStack {
                                    Text(topic.name)
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            topic.isFavorite.toggle()
                                        }
                                    }) {
                                        Image(systemName: "heart.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Favorites")
            }
        }
    }
    
    // MARK: - Settings Tab View
    private var settingsTab: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    HStack {
                        Label("Current Theme", systemImage: darkModeEnabled ? "moon.fill" : "sun.max.fill")
                        Spacer()
                        Text(darkModeEnabled ? "Dark" : "Light")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("App Info")) {
                    HStack {
                        Text("Total Topics")
                        Spacer()
                        Text("\(topics.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Favorite Topics")
                        Spacer()
                        Text("\(favoriteTopics.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Actions")) {
                    Button(action: { showAddTopicSheet = true }) {
                        Label("Add New Topic", systemImage: "plus.circle.fill")
                    }
                    
                    Button(action: {
                        shareText = "Check out these topics: \(topics.map { $0.name }.joined(separator: ", "))"
                        showShareSheet = true
                    }) {
                        Label("Share Topics", systemImage: "square.and.arrow.up")
                    }
                    .sheet(isPresented: $showShareSheet) {
                        ShareSheet(items: [shareText])
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Add Topic Sheet
    private var addTopicSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Topic")) {
                    TextField("Topic name", text: $newTopicName)
                }
                
                Section {
                    Button(action: {
                        if !newTopicName.isEmpty {
                            let newTopic = Topic(name: newTopicName, isFavorite: false)
                            topics.append(newTopic)
                            newTopicName = ""
                            showAddTopicSheet = false
                        }
                    }) {
                        Text("Add Topic")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(newTopicName.isEmpty)
                }
            }
            .navigationTitle("Add New Topic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newTopicName = ""
                        showAddTopicSheet = false
                    }
                }
            }
        }
    }
}

//
//  DetailView.swift
//  Displays information about the selected topic
//

struct DetailView: View {
    @Binding var topic: Topic
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text(topic.name)
                .font(.largeTitle)
                .bold()
            Text("Details for \(topic.name)")
                .font(.title3)
                .foregroundColor(.secondary)
            
            AsyncImage(url: URL(string: "https://picsum.photos/300"))
                .scaledToFit()
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
            
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation {
                        topic.isFavorite.toggle()
                    }
                }) {
                    Label(topic.isFavorite ? "Favorited" : "Add to Favorites", 
                          systemImage: topic.isFavorite ? "heart.fill" : "heart")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(topic.isFavorite ? .red : .blue)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle(topic.name)
    }
}

// MARK: - ShareSheet Helper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

//
// MARK: - Preview
//

