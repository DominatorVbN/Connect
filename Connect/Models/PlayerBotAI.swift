//
//  PlayerBotAI.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation
import Distributed
import ActorSystem

protocol PlayerBotAI {
    mutating func decideNextMove(given gameState: inout GameState) throws -> GameMove
}

/// The difficulty of the AI. We only implement an "easy" mode which picks moves at random.
///
/// This type is `Sendable` but not `Codable`; We are able to pass it to a distributed actor while initializing it,
/// however we cannot query it (without making it `Codable`) from a distributed actor since that may potentially
/// involve a remote call, which this type (for sake or argument), cannot handle (as it is not `Codable`).
public enum BotAIDifficulty: Sendable {
    case easy
}

extension GameState {
    public var availableVerticalPositions: [Int] {
        return verticalLines.enumerated().filter {
            $0.element.type == .empty
        }.map {
            $0.offset
        }
    }
    
    public var availableHoriPositions: [Int] {
        return horizontalLines.enumerated().filter {
            $0.element.type == .empty
        }.map {
            $0.offset
        }
    }
}

class RandomPlayerBotAI: PlayerBotAI {
    let playerID: ActorIdentity
    
    private var movesMade: Int = 0
    
    init(playerID: ActorIdentity) {
        self.playerID = playerID
    }
    
    init(playerID: LocalTestingDistributedActorSystem.ActorID) {
        self.playerID = .init(id: playerID.id)
    }
    
    func decideNextMove(given gameState: inout GameState) throws -> GameMove {
        var selection: Selection?
        let isVertical = [0,1].randomElement() ?? 0
        if isVertical == 0 {
            for position in gameState.availableVerticalPositions.shuffled() {
                selection = .vertical(index: position)
                break
            }
        } else {
            for position in gameState.availableHoriPositions.shuffled() {
                selection = .horizontal(index: position)
                break
            }
        }
        
        
        guard let selection = selection else {
            throw NoMoveAvailable()
        }
        
        let move = GameMove(playerID: playerID, selection: selection)
        movesMade += 1
        try gameState.mark(move)
        return move
    }
}

struct NoMoveAvailable: Error {}
