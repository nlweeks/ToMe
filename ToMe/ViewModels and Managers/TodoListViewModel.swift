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
    private let dataSource: SwiftDataSource
    
    // MARK: Todos Loaded To Memory
    var todos: [TodoItem] = []
    
    // MARK: Init
    init(with dataSource: SwiftDataSource) {
        self.dataSource = dataSource
        
        Task { @MainActor in
            todos = dataSource.fetchTodos()
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
    
    // MARK: Searching
    var searchQuery: String = ""
    var searchResults: [TodoItem] {
        if searchQuery.isEmpty {
            return todos
        } else {
            return todos.filter {
                $0.title.lowercased().contains(searchQuery.lowercased())
            }
        }
    }
    
    // MARK: Data source interfacing
    func fetchTodos(sortedBy method: SortMethod = .storedOrder) {
        Task { @MainActor in
            todos = dataSource.fetchTodos(sortedBy: method)
        }
        updateIndices()
    }
    
    func insertTodo(_ todo: TodoItem) {
        Task { @MainActor in
            dataSource.insert(todo)
            todos = dataSource.fetchTodos()
        }
        updateIndices()
    }
    
    func deleteTodos(at offsets: IndexSet) {
        Task { @MainActor in
            offsets.forEach { index in
                let todo = todos[index]
                dataSource.delete(todo)
            }
            todos = dataSource.fetchTodos()
        }
        updateIndices()
    }
    
    func deleteTodo(_ todo: TodoItem) {
        Task { @MainActor in
            if todos.firstIndex(of: todo) != nil {
                dataSource.delete(todo)
            }
            todos = dataSource.fetchTodos()
        }
        updateIndices()
    }
    
    // MARK: Testing functions
    func preloadSampleData() {
        let sampleTodos = TodoItem.samplesWithOrderIndices()
        Task { @MainActor in
            for todo in sampleTodos {
                dataSource.insert(todo)
            }
        }
        fetchTodos()
    }

    // MARK: - Selection Management
    var selectedIds = Set<UUID>()
    var isSelectAllActive = false

    // Check if all items are selected
    var areAllItemsSelected: Bool {
        selectedIds.count == todos.count && !todos.isEmpty
    }

    // Clear all selections
    func clearAllSelections() {
        selectedIds.removeAll()
        isSelectAllActive = false
    }

    // Select all items
    func selectAllItems() {
        selectedIds = Set(todos.map { $0.id })
        isSelectAllActive = true
    }

    // Toggle selection state
    func toggleSelectAll() {
        if areAllItemsSelected {
            clearAllSelections()
        } else {
            selectAllItems()
        }
    }

    // Toggle single item selection
    func toggleItemSelection(id: UUID) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
        // Update the isSelectAllActive state based on the current selection
        isSelectAllActive = areAllItemsSelected
    }

    // Check if an item is selected
    func isItemSelected(_ id: UUID) -> Bool {
        return selectedIds.contains(id)
    }
}

