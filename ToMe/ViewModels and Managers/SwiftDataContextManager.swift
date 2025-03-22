//
//  SwiftDataContextManager.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import Foundation
import SwiftData

// Context is the bridge between UI and SwiftData, it is NOT the data itself / source of truth
class SwiftDataContextManager {
    static let shared = SwiftDataContextManager()
    
    var container: ModelContainer?
    var context: ModelContext?
    
    private init() {
        do {
            container = try ModelContainer(for: TodoItem.self)
            if let container {
                context = ModelContext(container)
            }
        } catch {
            debugPrint("Error initializing database container:", error)
        }
    }
}
