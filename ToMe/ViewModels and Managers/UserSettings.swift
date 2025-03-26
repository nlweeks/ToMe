//
//  UserSettings.swift
//  ToMe
//
//  Created by Noah Weeks on 3/25/25.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var shouldSortByCompletion = true
}

extension View {
    func sortByCompletion(_ sortByCompletion: Bool) -> some View {
        environment(\.shouldSortByCompletion, sortByCompletion)
    }
}
