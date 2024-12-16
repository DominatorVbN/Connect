//
//  BotPlayer.swift
//  Connect
//
//  Created by Amit Samant on 06/12/24.
//

import Foundation
import ActorSystem

public actor BotPlayer: Identifiable {
    nonisolated public let id: ActorIdentity = .random
    
    var botAI: RandomPlayerBotAI
    var gameState: GameState
    
    public init() {
        self.gameState = .init()
        self.botAI = RandomPlayerBotAI(playerID: self.id)
    }
    
    public func makeMove() throws -> GameMove {
        return try botAI.decideNextMove(given: &gameState)
    }
    
    public func opponentMoved(_ move: GameMove) async throws {
        try gameState.mark(move)
    }
}
