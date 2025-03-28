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
    var notes: String
    var creationDate: Date
    var isCompleted: Bool
    var orderIndex: Int? = nil
    
    init(
        id: UUID = .init(),
        title: String,
        notes: String,
        creationDate: Date = .now,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.creationDate = creationDate
        self.isCompleted = isCompleted
    }
}

extension TodoItem {
    static var sampleData: [TodoItem] {
        [
            TodoItem(title: "Buy groceries",
                    notes: "Milk, eggs, bread, and vegetables for the week",
                    creationDate: Date().addingTimeInterval(-86400 * 2), // 2 days ago
                    isCompleted: true),
                    
            TodoItem(title: "Complete SwiftUI tutorial",
                    notes: "Finish the section on Core Data and SwiftData integration",
                    creationDate: Date().addingTimeInterval(-86400 * 5), // 5 days ago
                    isCompleted: false),
                    
            TodoItem(title: "Call dentist",
                    notes: "Schedule a checkup appointment for next month",
                    creationDate: Date().addingTimeInterval(-3600 * 4), // 4 hours ago
                    isCompleted: false),
                    
            TodoItem(title: "Fix app bugs",
                    notes: "Address the sorting issue and UI glitches in the detail view",
                    creationDate: Date().addingTimeInterval(-86400 * 1), // 1 day ago
                    isCompleted: false),
                    
            TodoItem(title: "Prepare presentation",
                    notes: "Create slides for the team meeting on Friday",
                    creationDate: Date().addingTimeInterval(-3600 * 12), // 12 hours ago
                    isCompleted: true),
                    
            TodoItem(title: "Update resume",
                    notes: "Add recent projects and update skills section",
                    creationDate: Date().addingTimeInterval(-86400 * 7), // 1 week ago
                    isCompleted: false),
                    
            TodoItem(title: "Plan weekend trip",
                    notes: "Research hotels and activities for next month's getaway",
                    creationDate: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                    isCompleted: false),
                    
            TodoItem(title: "Attend yoga class",
                    notes: "Thursday 6PM at Downtown Fitness Center",
                    creationDate: Date().addingTimeInterval(-86400 * 1.5), // 1.5 days ago
                    isCompleted: true),
                    
            TodoItem(title: "Write blog post",
                    notes: "Share learnings about SwiftData migration",
                    creationDate: Date(), // today
                    isCompleted: false),
                    
            TodoItem(title: "Return Amazon package",
                    notes: "Drop off at UPS store before Friday",
                    creationDate: Date().addingTimeInterval(-3600 * 36), // 36 hours ago
                    isCompleted: false)
        ]
    }
    
    // Set correct order indices based on the array order
    static func samplesWithOrderIndices() -> [TodoItem] {
        let samples = sampleData
        for (index, item) in samples.enumerated() {
            item.orderIndex = index
        }
        return samples
    }
    
    // Generate a random new todo item (useful for testing)
    static func randomTodo() -> TodoItem {
        let titles = ["Review code", "Send email", "Update documentation",
                     "Exercise", "Read book", "Water plants",
                     "Pay bills", "Clean kitchen", "Backup files"]
        
        let descriptions = ["This needs to be done soon", "Low priority but important",
                           "Don't forget about this", "Should take about 30 minutes",
                           "Will make a big difference", "Been putting this off"]
        
        // Random date within the last 10 days
        let randomTimeInterval = Double.random(in: -86400 * 10 ... 0)
        let randomDate = Date().addingTimeInterval(randomTimeInterval)
        
        // 30% chance of being completed
        let randomIsCompleted = Bool.random(probability: 0.3)
        
        return TodoItem(
            title: titles.randomElement() ?? "New task",
            notes: descriptions.randomElement() ?? "Task description",
            creationDate: randomDate,
            isCompleted: randomIsCompleted
        )
    }
    
    // Generate multiple random todos
    static func generateRandomTodos(count: Int) -> [TodoItem] {
        var todos: [TodoItem] = []
        for i in 0..<count {
            let todo = randomTodo()
            todo.orderIndex = i
            todos.append(todo)
        }
        return todos
    }
}

// Helper extension for random boolean generation
extension Bool {
    static func random(probability: Double = 0.5) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
