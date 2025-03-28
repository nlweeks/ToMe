//
//  TodoDetailView.swift
//  ToMe
//
//  Created by Noah Weeks on 3/28/25.
//

import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Bindable var viewModel: TodoListViewModel
    @Bindable var todo: TodoItem
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Title", text: $todo.title)
                .padding(.top)
            TextField("Notes", text: $todo.notes)
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.3), .large])
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var isPresented = true
        let viewModel: TodoListViewModel

        var body: some View {
            Button("Present") {
                isPresented.toggle()
            }
            Color.clear // base view
                .sheet(isPresented: $isPresented) {
                    TodoDetailView(viewModel: viewModel, todo: sampleTodo)
                }
        }

        var sampleTodo: TodoItem {
            TodoItem(title: "Preview Task", notes: "This is a sample.", creationDate: .now)
        }
    }

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
    let context = ModelContext(container)
    let viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: context))

    return PreviewWrapper(viewModel: viewModel)
}
