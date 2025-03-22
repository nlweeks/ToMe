//
//  TodoListViewModel.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import Foundation
import SwiftUI

@Observable
class TodoListViewModel {
    // MARK: Data Source
    private let dataSource: SwiftDataLocalSource
    
    // MARK: Todos Loaded To Memory
    var todos: [TodoItem] = []
    
    // MARK: Init
    init(with dataSource: SwiftDataLocalSource) {
        self.dataSource = dataSource
        
        Task { @MainActor in
            todos = dataSource.fetch()
        }
    }
    
    // MARK: Adding New Todo
    var newTodo: TodoItem?
    var isAddingTodo: Bool = false
    
    func prepareNewTodo() {
        newTodo = TodoItem(id: UUID(), title: "", todoDescription: "", creationDate: Date(), isCompleted: false)
        isAddingTodo = true
    }
    
    func saveNewTodo() {
        guard let newTodo = newTodo else { return }
        insertTodo(newTodo)
        clearNewTodo()
    }
    
    func clearNewTodo() {
        newTodo = nil
        isAddingTodo = false
    }
    
    // MARK: New Todo UI Bindings
    var newTodoTitleBinding: Binding<String> {
        Binding(
            get: { self.newTodo?.title ?? "" },
            set: { self.newTodo?.title = $0 }
        )
    }
    
    var newTodoDescriptionBinding: Binding<String> {
        Binding(
            get: { self.newTodo?.todoDescription ?? "" },
            set: { self.newTodo?.todoDescription = $0 }
        )
    }
    
    // MARK: Sorting
    private func updateIndices() {
        for (index, todo) in todos.enumerated() {
            todo.orderIndex = index
        }
    }
    
    func moveTodo(from source: IndexSet, to destination: Int) {
        todos.move(fromOffsets: source, toOffset: destination)
        updateIndices()
        
    }
    
    // MARK: Data source interfacing
    func insertTodo(_ todo: TodoItem) {
        Task { @MainActor in
            dataSource.insert(todo)
            todos = dataSource.fetch()
        }
        updateIndices()
    }
    
    func deleteTodos(at offsets: IndexSet) {
        Task { @MainActor in
            offsets.forEach { index in
                let todo = todos[index]
                dataSource.delete(todo)
            }
            todos = dataSource.fetch()
        }
        updateIndices()
    }
}

