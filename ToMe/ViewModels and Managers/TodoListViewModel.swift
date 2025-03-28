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
    
    // MARK: Master Todo List & Visible Todo List
    private var allTodos: [TodoItem] = [] {
        didSet {
            sortTodos() // Update visible list when master list changes
        }
    }
    var todos: [TodoItem] = []  // Visible, filtered list
    
    // MARK: Shared constants
    private let animationDuration: Double = 0.3
    private let animationDelayNanos: UInt64 = 300_000_000
    
    // MARK: Init
    init(with dataSource: SwiftDataSource) {
        self.dataSource = dataSource
        
        Task { @MainActor in
            fetchTodos()
        }
    }
    
    // MARK: UI Bindings
    var newTodoTitleBinding: Binding<String> {
        Binding(
            get: { self.newTodo?.title ?? "" },
            set: { self.newTodo?.title = $0 }
        )
    }
    var newTodoDescriptionBinding: Binding<String> {
        Binding(
            get: { self.newTodo?.notes ?? "" },
            set: { self.newTodo?.notes = $0 }
        )
    }
    
    func todoTitleBinding(for todo: TodoItem) -> Binding<String> {
        Binding(
            get: { todo.title },
            set: { newValue in
                // Find and update the todo in your data source
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos[index].title = newValue
                    Task { @MainActor in
                        self.dataSource.update()
                    }
                }
            }
        )
    }
    
    // MARK: Adding New Todo
    var newTodo: TodoItem?
    var isAddingTodo: Bool = false
    
    func prepareNewTodo() {
        newTodo = TodoItem(id: UUID(), title: "", notes: "", creationDate: Date(), isCompleted: false)
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
    var showCompletedTodos: Bool = PreferencesManager.shared.showCompletedTodos {
        didSet {
            PreferencesManager.shared.showCompletedTodos = showCompletedTodos
            sortTodos()
        }
    }
    
    func showHideCompletedTodos() {
        let newValue = !showCompletedTodos
        DispatchQueue.main.async {
            self.showCompletedTodos = newValue
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
    }
    
    func sortTodos() {
        let completedTodos = allTodos.filter { $0.isCompleted }
            .sorted(by: sortMethod.sortClosure)
        let uncompletedTodos = allTodos.filter { !$0.isCompleted }
            .sorted(by: sortMethod.sortClosure)
        let sortedTodos = uncompletedTodos + (showCompletedTodos ? completedTodos : [])
        // Removed withAnimation wrapper
        todos = sortedTodos
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
            allTodos = dataSource.fetchTodos(sortedBy: sortMethod)
        }
    }
    
    func insertTodo(_ todo: TodoItem) {
        Task { @MainActor in
            dataSource.insert(todo)
            fetchTodos() // Refresh master list
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
        
        todos.removeAll { todo in
            todosToRemove.contains(where: { $0.id == todo.id })
        }
        
        Task { @MainActor in
            for todo in todosToRemove {
                dataSource.delete(todo)
            }
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
        // Directly toggle and update; let the view animate the list changes.
        todo.isCompleted.toggle()
        Task { @MainActor in
            dataSource.update()
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

