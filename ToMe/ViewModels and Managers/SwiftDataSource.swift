//
//  SwiftDataSource.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataSource {
    private var container: ModelContainer?
    private var context: ModelContext?
    
    init(container: ModelContainer?, context: ModelContext?) {
        self.container = container
        self.context = context
    }
}

// MARK: Adding, deleting, fetching, sort fetching
extension SwiftDataSource {
    func insert(_ entity: TodoItem) {
        self.container?.mainContext.insert(entity)
        try? self.container?.mainContext.save()
    }
    
    func delete(_ entity: TodoItem) {
        self.container?.mainContext.delete(entity)
        try? self.container?.mainContext.save()
    }
    
    func fetchTodos(sortedBy method: SortMethod = .storedOrder) -> [TodoItem] {
        let fetchDescriptor = FetchDescriptor<TodoItem>(sortBy: [method.sortDescriptor])
        let todos = try? self.container?.mainContext.fetch(fetchDescriptor)
        return todos ?? []
    }
    
    func update() {
        try? self.container?.mainContext.save()
    }
}
