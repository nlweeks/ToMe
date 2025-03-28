//
//  TodoRowView.swift
//  ToMe
//
//  Created by Noah Weeks on 3/26/25.
//

import SwiftUI

struct TodoRowView: View {
    @Bindable var viewModel: TodoListViewModel
    let todo: TodoItem
    let isEditMode: Bool
    var focusedField: FocusState<String?>.Binding
    let fieldId: String
    @State private var showDetailView: Bool = false
    
    private var isFieldFocused: Bool {
        focusedField.wrappedValue == fieldId
    }
    
    var body: some View {
        Button {
            showDetailView = true
        } label: {
            HStack {
                Text(todo.title)
                    .foregroundColor(todo.isCompleted ? .gray : .primary)
            }
        }
        .disabled(isEditMode)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteTodo(todo)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showDetailView) {
            TodoDetailView(viewModel: viewModel, todo: todo)
        }
    }
}
