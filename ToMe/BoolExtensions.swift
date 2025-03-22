//
//  BoolExtensions.swift
//  ToMe
//
//  Created by Noah Weeks on 3/22/25.
//

import Foundation

extension Bool: @retroactive Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        // the only true inequality is false < true
        !lhs && rhs
    }
}
