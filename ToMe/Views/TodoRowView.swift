////
////  TodoRowView.swift
////  ToMe
////
////  Created by Noah Weeks on 3/24/25.
////
//
//import SwiftUI
//
//struct TodoRowView: View {
//    let todo: TodoItem
//    @Bindable var viewModel: TodoListViewModel
//    @Environment(\.editMode) private var editMode
//    
//    var body: some View {
//        HStack {
//            if editMode?.wrappedValue.isEditing == true {
//                // Custom selection control in edit mode
//                Button(action: {
//                    viewModel.toggleItemSelection(id: todo.id)
//                }) {
//                    Image(systemName: viewModel.selectedIds.contains(todo.id) ? "checkmark.circle.fill" : "circle")
//                        .foregroundColor(viewModel.selectedIds.contains(todo.id) ? .blue : .gray)
//                        .animation(.default, value: viewModel.selectedIds.contains(todo.id))
//                }
//            } else {
//                // Show completion status when not in edit mode
//                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
//                    .foregroundColor(todo.isCompleted ? .blue : .gray)
//            }
//            
//            Text(todo.title)
//        }
//        .contentShape(Rectangle()) // Make the whole row tappable
//        .onTapGesture {
//            if editMode?.wrappedValue.isEditing == true {
//                viewModel.toggleItemSelection(id: todo.id)
//            }
//        }
//    }
//}
