//
//  PreferencesManager.swift
//  ToMe
//
//  Created by Noah Weeks on 3/25/25.
//

import Foundation
import SwiftUI
import Combine

// 1. Create a separate preferences manager class
class PreferencesManager {
    // Singleton for easy access
    static let shared = PreferencesManager()
    
    // Properties with @AppStorage
    @AppStorage("showCompletedTodos") var showCompletedTodos: Bool = true
    @AppStorage("sortMethod") var sortMethod: SortMethod = .title
    
    private init() {}
    
    // Optional: Publisher for reactive updates (if using Combine)
    var preferencesDidChange = PassthroughSubject<Void, Never>()
    
    // Call this when any preference changes to notify observers
    func notifyChanges() {
        preferencesDidChange.send()
    }
}
