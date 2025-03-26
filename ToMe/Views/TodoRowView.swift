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
        HStack {
            

            TextField("Todo Title", text: viewModel.todoTitleBinding(for: todo))
                .foregroundColor(todo.isCompleted ? .gray : .primary)
                .textFieldStyle(.plain)
                .focused(focusedField, equals: fieldId)
                .disabled(isEditMode)
                        .animation(nil, value: isEditMode)
            
            Spacer()
            
            ZStack {
                Button {
                    showDetailView.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                // Toggle opacity based on whether the row is focused and not in edit mode.
                .opacity(isFieldFocused && !isEditMode ? 1 : 0)
                .disabled(isEditMode)
                // Animate changes in edit mode with a built-in easeInOut.
                .animation(.easeInOut(duration: 0.35), value: isEditMode)
            }
            .frame(width: 30) // Fixed width for consistent layout
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteTodo(todo)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .selectionDisabled(!isEditMode)
        .sheet(isPresented: $showDetailView) {
            TodoDetailView(viewModel: viewModel, todo: todo)
        }
    }
}

struct TodoDetailView: View {
    @Bindable var viewModel: TodoListViewModel
    var todo: TodoItem
    
    var body: some View {
        VStack {
            Text(todo.title)
        }
    }
}
