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
    }
    
    func sortTodos() {
        var newTodos = todos
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
        
        if sortByCompletionStatus {
            todos = uncompletedTodos + (showCompletedTodos ? completedTodos : [])
        } else {
            todos = newTodos.sorted(by: sortMethod.sortClosure)
        }
        
        updateIndices()
    }
    
    func moveTodo(from source: IndexSet, to destination: Int) {
        todos.move(fromOffsets: source, toOffset: destination)
        sortMethod = .storedOrder
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
        withAnimation {
            todo.isCompleted.toggle()
        }
        
        Task { @MainActor in
            dataSource.update(todo)
            sortTodos()
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

