//
//  GamePlayer.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation

public typealias MyPlayer = OfflineGamePlayer
public typealias OpponentPlayer = BotPlayer

public protocol GamePlayer {
    var id: UUID { get }
    var name: String { get }
}

public actor OfflineGamePlayer: GamePlayer {
    nonisolated public let id: UUID = UUID()
    public let name: String
    let model: GameViewModel
    var movesMade: Int = 0
    
    public init(name: String, model: GameViewModel) {
        self.name = name
        self.model = model
    }
    
    public func makeMove(_ selection: Selection) async throws -> GameMove {
        let move = GameMove(playerID: id, selection: selection)
        _ = await model.userMadeMove(move: move)
        movesMade += 1
        return move
    }
    
    public func opponentMoved(_ move: GameMove) async throws {
         do {
             try await model.markOpponentMove(move)
         } catch {
             print("player", "Opponent made illegal move! \(move)")
         }
     }
    
    /// Poll move from UI by awaiting on user clicking one of the game fields.
    public func makeMove() async throws -> GameMove {
        let selection = await model.humanSelectedField()
        movesMade += 1
        let move = GameMove(
            playerID: self.id,
            selection: selection
        )
        return move
    }
    
}
