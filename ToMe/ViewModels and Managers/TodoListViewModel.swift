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
    
    // MARK: Preferences Manager
    private let preferences = PreferencesManager.shared
    
    // MARK: Working Todo List
    var todos: [TodoItem] = []
    
    // MARK: Shared constants
    private let animationDuration: Double = 0.3
    private let animationDelayNanos: UInt64 = 300_000_000
    
    // MARK: Init
    init(with dataSource: SwiftDataSource) {
        self.dataSource = dataSource
        
        Task { @MainActor in
            todos = dataSource.fetchTodos()
        }
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
    
    // MARK: Sorting
    var sortByCompletionStatus: Bool {
        get { preferences.sortByCompletionStatus }
        set {
            preferences.sortByCompletionStatus = newValue
            sortTodos()
        }
    }
    var showCompletedTodos: Bool {
        get { preferences.showCompletedTodos }
        set {
            preferences.showCompletedTodos = newValue
            sortTodos()
        }
    }
    var sortMethod: SortMethod {
        get { preferences.sortMethod }
        set {
            preferences.sortMethod = newValue
            sortTodos()
        }
    }
    
    private func updateIndices() {
        for (index, todo) in todos.enumerated() {
            todo.orderIndex = index
        }
        updateDatabase()
    }
    
    private func updateDatabase() {
        Task { @MainActor in
            dataSource.update()
        }
    }
    
    func sortTodos() {
        let oldTodos = todos // Keep track of original state
        let newTodos = todos
        var completedTodos: [TodoItem] = []
        var uncompletedTodos: [TodoItem] = []
        
        for todo in newTodos {
            if todo.isCompleted {
                completedTodos.append(todo)
            } else {
                uncompletedTodos.append(todo)
            }
        }
        
        completedTodos.sort(by: sortMethod.sortClosure)
        uncompletedTodos.sort(by: sortMethod.sortClosure)
        
        // Prepare the new order before applying it
        let sortedTodos = sortByCompletionStatus
            ? uncompletedTodos + (showCompletedTodos ? completedTodos : [])
            : newTodos.sorted(by: sortMethod.sortClosure)
        
        // Apply the changes with animation
        withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
            todos = sortedTodos
        }
        
        // Update indices after animation has been triggered
        updateIndices()
    }
    
    func moveTodo(from source: IndexSet, to destination: Int) {
        Task { @MainActor in
            todos.move(fromOffsets: source, toOffset: destination)
            
            for (index, todo) in todos.enumerated() {
                todo.orderIndex = index
            }
            
            dataSource.update()
            preferences.sortMethod = .storedOrder
        }
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
    func fetchTodos() {
        Task { @MainActor in
            todos = dataSource.fetchTodos(sortedBy: sortMethod)
            sortTodos()
        }
    }
    
    func insertTodo(_ todo: TodoItem) {
        Task { @MainActor in
            do {
                dataSource.insert(todo)
                fetchTodos()
            }
        }
    }
    
    // MARK: - Selection Management
    var selectedIds = Set<UUID>()
    var isSelectAllActive = false
    var areAllItemsSelected: Bool {
        selectedIds.count == todos.count && !todos.isEmpty
    }
    
    func clearAllSelections() {
        selectedIds.removeAll()
        isSelectAllActive = false
    }
    
    func selectAllItems() {
        selectedIds = Set(todos.map { $0.id })
        isSelectAllActive = true
    }
    
    func toggleSelectAll() {
        if areAllItemsSelected {
            clearAllSelections()
        } else {
            selectAllItems()
        }
    }
    
    func toggleItemSelection(id: UUID) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
        
        isSelectAllActive = areAllItemsSelected
    }
    
    func isItemSelected(_ id: UUID) -> Bool {
        return selectedIds.contains(id)
    }
    
    // MARK: Deleting todos
    private func deleteTodosImplementation(todosToRemove: [TodoItem], clearSelections: Bool = false) {
        if todosToRemove.isEmpty { return }
        
        withAnimation(.easeInOut(duration: animationDuration)) {
            todos.removeAll { todo in
                todosToRemove.contains(where: { $0.id == todo.id })
            }
        }
        
        Task { @MainActor in
            for todo in todosToRemove {
                dataSource.delete(todo)
            }
            
            try? await Task.sleep(nanoseconds: animationDelayNanos)
            fetchTodos()
            
            if clearSelections {
                clearAllSelections()
            }
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        deleteTodosImplementation(todosToRemove: [todo])
    }
    
    func deleteSelectedTodos() {
        let todosToRemove = todos.filter { selectedIds.contains($0.id) }
        deleteTodosImplementation(todosToRemove: todosToRemove, clearSelections: true)
    }
    
    func deleteTodos(at indexSet: IndexSet) {
        let todosToRemove = indexSet.map { todos[$0] }
        deleteTodosImplementation(todosToRemove: todosToRemove)
    }
    
    // MARK: Complete todos
    func markTodoAsCompleted(_ todo: TodoItem) {
        // Apply animations to the toggle
        withAnimation(.spring(duration: 0.3)) {
            todo.isCompleted.toggle()
        }
        
        // Let the system process the toggle before sorting
        Task { @MainActor in
            // Wait a tiny fraction of a second to let the toggle animation finish
            try? await Task.sleep(nanoseconds: 400_000_000)
            
            // When the item is completed, apply sorting with animation
            dataSource.update()
            sortTodos() // Now uses animation internally
        }
    }
    
    // MARK: Testing functions
    func preloadSampleData() {
        let sampleTodos = TodoItem.samplesWithOrderIndices()
        
        Task { @MainActor in
            for todo in sampleTodos {
                dataSource.insert(todo)
            }
            fetchTodos()
        }
    }
}

