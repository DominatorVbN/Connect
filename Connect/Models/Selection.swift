//
//  Selection.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation

public enum Selection: Hashable, Sendable, Codable {
    case horizontal(index: Int)
    case vertical(index: Int)
}
