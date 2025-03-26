//
//  TodoListMenu.swift
//  ToMe
//
//  Created by Noah Weeks on 3/25/25.
//

import SwiftUI

struct TodoListMenu: View {
    @Bindable var viewModel: TodoListViewModel
    
    var body: some View {
        Menu(content:{
            Menu(content: {
                Button("Title") {
                    viewModel.sortMethod = .title
                    viewModel.sortTodos()
                }
                Button("Created") {
                    viewModel.sortMethod = .created
                    viewModel.sortTodos()
                }
            }, label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            })
            Button {
                viewModel.showHideCompletedTodos()
            } label: {
                Label(viewModel.showCompletedTodos ? "Hide Completed" : "Show Completed",
                      systemImage: viewModel.showCompletedTodos ? "checkmark.circle.fill" : "circle")
            }
        }, label: {
            Label("Options", systemImage: "ellipsis.circle")
        })
        .menuStyle(.button)
    }
}
