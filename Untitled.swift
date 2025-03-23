//
//  Untitled.swift
//  ToMe
//
//  Created by Noah Weeks on 3/22/25.
//

import SwiftUI

struct Book: Identifiable, Hashable {
    let name: String
    let id = UUID()
}
private var books = [
    Book(name: "SwiftUI"),
    Book(name: "Swift"),
    Book(name: "Objective-C"),
    Book(name: "C#"),
    Book(name: "Java"),
    Book(name: "SwiftUI"),
    Book(name: "Swift"),
    Book(name: "Objective-C"),
    Book(name: "C#"),
    Book(name: "Java")
]
struct TestView: View {
    @State private var multiSelection = Set<UUID>()
    var body: some View {
        NavigationView {
            List(books, selection: $multiSelection) {
                Text($0.name)
            }
            .navigationTitle("Books")
            .toolbar { EditButton() }
        }
        Text("\(multiSelection.count) selected")
    }
}

#Preview {
    TestView()
}
