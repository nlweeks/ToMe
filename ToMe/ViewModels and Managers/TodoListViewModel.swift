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
    
    var areCompletedTodosAtBottom: Bool = true
    
    private func moveCompletedTodosToEnd() {
        todos.sort { (todo1, todo2) -> Bool in
            todo1.isCompleted != todo2.isCompleted
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
        if areCompletedTodosAtBottom {
            moveCompletedTodosToEnd()
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
    
    func deleteTodo(_ todo: TodoItem) {
        // First, check if todo exists in our array
        if todos.firstIndex(of: todo) != nil {
            // Use withAnimation for the UI update
            withAnimation(.easeInOut(duration: 0.3)) {
                // Remove from local array
                todos.removeAll { $0.id == todo.id }
            }
            
            // Delete from data source without capturing self in Task
            Task { @MainActor in
                dataSource.delete(todo)
                
                // Refresh todos after a short delay to let animation complete
                try? await Task.sleep(nanoseconds: 300_000_000)
                todos = dataSource.fetchTodos()
                updateIndices()
            }
        }
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
    
    func deleteSelectedTodos() {
        // Get the todos to delete
        let todosToRemove = todos.filter { selectedIds.contains($0.id) }
        
        // Skip if nothing to delete
        if todosToRemove.isEmpty { return }
        
        // Use withAnimation for the UI update
        withAnimation(.easeInOut(duration: 0.3)) {
            // Remove from the local array for immediate UI update
            todos.removeAll { todo in
                selectedIds.contains(todo.id)
            }
        }
        
        // Delete from data source without capturing self in complex closure
        Task { @MainActor in
            // Delete each todo from the data source
            for todo in todosToRemove {
                dataSource.delete(todo)
            }
            
            // Refresh todos after a short delay to let animation complete
            try? await Task.sleep(nanoseconds: 300_000_000)
            todos = dataSource.fetchTodos()
            updateIndices()
            
            // Clear selection
            clearAllSelections()
        }
    }
    
    func deleteTodos(at indexSet: IndexSet) {
        // Get the todos to delete
        let todosToRemove = indexSet.map { todos[$0] }
        
        // Use withAnimation for the UI update
        withAnimation(.easeInOut(duration: 0.3)) {
            // Remove from the local array
            todos.remove(atOffsets: indexSet)
        }
        
        // Delete from data source
        Task { @MainActor in
            // Delete each todo from the data source
            for todo in todosToRemove {
                dataSource.delete(todo)
            }
            
            // Refresh todos after a short delay to let animation complete
            try? await Task.sleep(nanoseconds: 300_000_000)
            todos = dataSource.fetchTodos()
            updateIndices()
        }
    }
    
    // MARK: Complete todos
    // Complete targeted todo
    func markTodoAsCompleted(_ todo: TodoItem) {
        withAnimation {
            todo.isCompleted.toggle()
        }
    }
}

