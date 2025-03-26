//
//  SortMethod.swift
//  ToMe
//
//  Created by Noah Weeks on 3/22/25.
//

import Foundation

enum SortMethod: String, CaseIterable {
    case storedOrder
    case title
    case created
    case completion
    
    var sortDescriptor: SortDescriptor<TodoItem> {
        switch self {
        case .storedOrder:
            return SortDescriptor(\TodoItem.orderIndex)
        case .title:
            return SortDescriptor(\TodoItem.title, order: .forward)
        case .created:
            return SortDescriptor(\TodoItem.creationDate, order: .reverse)
        case .completion:
            return SortDescriptor(\TodoItem.isCompleted, order: .forward)
        }
    }
    
    var sortClosure: (TodoItem, TodoItem) -> Bool {
        switch self {
        case .storedOrder:
            return { $0.orderIndex ?? 0 < $1.orderIndex ?? 0 }
        case .title:
            return { $0.title < $1.title }
        case .created:
            return { $0.creationDate > $1.creationDate } // Newest first
        case .completion:
            return { $0.isCompleted && !$1.isCompleted }
        }
    }
}
