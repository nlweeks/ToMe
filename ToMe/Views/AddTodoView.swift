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
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Todo Title", text: viewModel.newTodoTitleBinding)
                TextField("Todo Description", text: viewModel.newTodoDescriptionBinding)
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
        
    }
}


#Preview {
    var container = try? ModelContainer()
    var context = container!.mainContext
    var viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: context))
    NavigationStack {
        AddTodoView(viewModel: viewModel)
    }
}
