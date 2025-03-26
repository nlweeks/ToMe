//
//  AddTodoView.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import SwiftUI
import SwiftData

struct AddTodoView: View {
    @Bindable var viewModel: TodoListViewModel
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isDescriptionFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Todo Title", text: viewModel.newTodoTitleBinding)
                    .focused($isTitleFocused)
                    
                    .onSubmit {
                        isDescriptionFocused = true
                    }
                TextField("Todo Description", text: viewModel.newTodoDescriptionBinding)
                    .focused($isDescriptionFocused)
            }
            .navigationTitle("Add Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.saveNewTodo()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.clearNewTodo()
                    }
                }
            }
        }
        .onAppear {
            isTitleFocused = true
        }
        .task {
            try? await Task.sleep(nanoseconds: 50_000_000)
            isTitleFocused = true
        }
    }
}


#Preview {
    let container = try? ModelContainer()
    let context = container!.mainContext
    let viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: context))
    NavigationStack {
        AddTodoView(viewModel: viewModel)
    }
}
