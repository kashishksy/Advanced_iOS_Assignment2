//
//  ContentView.swift
//  PostsApp_Assignment2
//
//  Created by Kashish Yadav on 2025-02-11.
//

import SwiftUI
import Foundation

//creating structs - Post and User

//Post model
struct Post: Decodable, Identifiable {
    
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

//User model
struct User: Decodable, Identifiable {
    
    let id: Int
    let email: String
    let name: String
}

//combining post with user
struct PostWithUser {
    let post: Post
    let user: User
}

class DataService{
    //singleton instance
    static let shared = DataService()
    
    //private init to conform to singleton pattern
    private init() {}
    
    //Fetch posts
        func fetchPosts() async throws -> [Post] {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode([Post].self, from: data)
        }
    
    //Fetch users
       func fetchUsers() async throws -> [User] {
           let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
           let (data, _) = try await URLSession.shared.data(from: url)
           return try JSONDecoder().decode([User].self, from: data)
       }
    
}

//combining posts with users
func combinePostsWithUsers(posts: [Post], users: [User]) -> [PostWithUser] {
    return posts.compactMap { post in
        if let user = users.first(where: { $0.id == post.userId }) {
            return PostWithUser(post: post, user: user)
        }
        return nil
    }
}

//creating viewModel to manage data
class ViewModel: ObservableObject {
    @Published var postsWithUsers: [PostWithUser] = []
    
    func loadData() async {
        do {
            let posts = try await DataService.shared.fetchPosts()
            let users = try await DataService.shared.fetchUsers()
            let combinedData = combinePostsWithUsers(posts: posts, users: users)
            
            DispatchQueue.main.async {
                self.postsWithUsers = combinedData
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    
    
    // Gradient background
        private let gradient = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.26, green: 0.63, blue: 0.96),   // Soft blue
                Color(red: 0.41, green: 0.35, blue: 0.80),   // Muted purple
                Color(red: 0.22, green: 0.82, blue: 0.73)    // Fresh teal
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    
    
    var body: some View {
       
        ZStack {
            // Full-screen gradient background
            gradient
                .ignoresSafeArea()
            ScrollView {
                
                VStack(spacing: 20) {
                    ForEach(viewModel.postsWithUsers, id: \.post.id) { item in
                        PostView(post: item.post, user: item.user)
                    }
                }
                
                .padding()
            }
        }
            
        
        .task {
            await viewModel.loadData()
        }
    }
}

struct PostView: View {
    let post: Post
    let user: User
    
    // Assign unique SF Symbols and colors
    private let sfSymbols = ["person.fill", "star.fill", "heart.fill", "flag.fill", "book.fill", "gear", "trophy.fill", "bell.fill", "tag.fill", "cart.fill"]
    private let colors: [Color] = [.red, .blue, .green, .orange, .purple, .pink, .yellow, .gray, .black, .brown]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(post.title)
                .font(.headline)
            Text(post.body)
                .font(.body)
                .foregroundColor(.secondary)
            HStack {
                Image(systemName: sfSymbols[user.id % sfSymbols.count])
                    .foregroundColor(colors[user.id % colors.count])
                Text(user.name)
                Text(user.email)
                    .foregroundColor(colors[user.id % colors.count])
            }
            .font(.subheadline)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

#Preview {
    ContentView()
}
