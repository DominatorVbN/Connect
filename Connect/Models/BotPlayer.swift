//
//  BotPlayer.swift
//  Connect
//
//  Created by Amit Samant on 06/12/24.
//

import Foundation

public actor BotPlayer: Identifiable, GamePlayer {
    
    nonisolated public let id: UUID = UUID()
    public let name: String = "Bot Player"
    
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
