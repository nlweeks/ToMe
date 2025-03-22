//
//  TodoItem.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import Foundation
import SwiftData

@Model
class TodoItem {
    var id: UUID
    var title: String
    var todoDescription: String
    var creationDate: Date
    var isCompleted: Bool
    var orderIndex: Int? = nil
    
    init(
        id: UUID = .init(),
        title: String,
        todoDescription: String,
        creationDate: Date = .now,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.todoDescription = todoDescription
        self.creationDate = creationDate
        self.isCompleted = isCompleted
    }
}

extension TodoItem {
    // TODO: Create dummy data
}
