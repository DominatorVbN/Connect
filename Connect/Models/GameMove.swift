//
//  GameMove.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation

public struct GameMove: Hashable, Sendable, Codable {
    /// Identity of the player actor who performed the move.
    public let playerID: UUID
    public let selection: Selection
    
    init(playerID: UUID, selection: Selection) {
        self.playerID = playerID
        self.selection = selection
    }
}
