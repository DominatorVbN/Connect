//
//  ContentViewModel.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation
import SwiftUI
import ActorSystem

@MainActor
public class GameViewModel: ObservableObject {
    
    @Published var gameState: GameState = GameState()
    @Published var opponent: OpponentPlayer?
    @Published var oppponentName: String? = nil
    @Published var waitingForOpponentMove: Bool = false
    @Published public var gameResult: GameResult?
    @Published public var lastMove: Selection? = nil
    

    var size: Int {
        gameState.size
    }
    
    public func userMadeMove(move: GameMove) -> GameResult? {
        do {
            try gameState.mark(move)
            
            gameResult = try gameState.checkWin()
            
            if let opponent = opponent {
                waitForOpponentMove(true)
                Task {
                    // inform the opponent about this player's move
                    try await opponent.opponentMoved(move)
                    
                    guard gameResult == nil else {
                        // we're done here, the game has some result already
                        return
                    }
                    
                    // the game is not over yet,
                    // ask the opponent to make their move:
                    let opponentMove = try await opponent.makeMove()
                    print("model", "Opponent moved: \(opponentMove)")
                    try markOpponentMove(opponentMove)
                }
            }
        } catch {
            print("game-model", "Move failed, error: \(error)")
        }
        return gameResult
    }
    
    public func foundOpponent(_ opponent: OpponentPlayer, myself: MyPlayer, informOpponent: Bool) {
        self.opponent = opponent
        Task {
            self.oppponentName = try await opponent.getName()
        }
        // STEP 2: local multiplayer, enable telling the other player
        if informOpponent {
            Task {
                try await opponent.startGameWith(opponent: myself, startTurn: false)
            }
        }
    }
    
    public func waitForOpponentMove(_ shouldWait: Bool) {
        print("model", "wait...")
        self.waitingForOpponentMove = shouldWait
    }
    
    public func markOpponentMove(_ move: GameMove) throws {
        print("model", "mark opponent move: \(move)")
       
        try gameState.mark(move)
        gameResult = try gameState.checkWin()
        
        // now we're free to make our own move, unless the game finished (see isGameDisabled)
        self.waitingForOpponentMove = false
    }
    
    func getHorizontalIndex(at indexPath: IndexPath) -> Int {
        let index = indexPath.row * (size - 1) + indexPath.section
        return index
    }
    
    /// Poll the UI, and therefore human player, to make a decision which field to make a move on.
    public func humanSelectedField() async -> Selection {

        for await position in $lastMove.values {
            guard let selectedPosition = position else {
                continue
            }
            
            lastMove = nil // reset the last move
            return selectedPosition
        }
        
        fatalError("Expected a position actually be selected")
    }
    
    public var isGameDisabled: Bool {
        // the game field is disabled when:
        
        // we don't have an opponent yet,
        opponent == nil ||
        // we are waiting for the opponent's move
        waitingForOpponentMove ||
        // or when the game has concluded
        gameResult != nil
    }
    
    
    // MARK: Used from view
    
    func horizontalLine(at indexPath: IndexPath) -> Line? {
        let index = getHorizontalIndex(at: indexPath)
        guard index < gameState.horizontalLines.count else {
            return nil
        }
        return gameState.horizontalLines[index]
    }
    
    private func rotatedIndexPath(from indexPath: IndexPath, size S: Int) -> IndexPath {
        let col = indexPath.section
        let row = indexPath.row
        
        let newRow = col
        let newCol = S - row
        return IndexPath(row: newRow, section: newCol)
    }
    
    func getVerticalIndex(at indexPath: IndexPath) -> Int {
        let newIndexPath = rotatedIndexPath(from: indexPath, size: size - 1)
        let index = newIndexPath.row * size + newIndexPath.section
        return index
    }
    
    func verticalLine(at indexPath: IndexPath) -> Line? {
        let index = getVerticalIndex(at: indexPath)
        guard index < gameState.verticalLines.count else {
            return nil
        }
        return gameState.verticalLines[index]
    }
    
    private func boxIndex(row: Int, col: Int) -> Int {
        let index = (row * (size-1) + col)
        return index
    }
    
    func getBox(at indexPath: IndexPath) -> Box {
        return gameState.boxes[boxIndex(row: indexPath.row, col: indexPath.section)]
    }
    
    func names(forPlayerIds playerIds: [ActorIdentity]) async throws -> [String] {
        var names: [String] = []
        for playerId in playerIds {
            let player = try localNetworkSystem.resolve(id: playerId, as: DistubutedPlayer.self)
            let name = try await player?.getName()
            if let name {
                names.append(name)
            }
        }
        return names
    }
    
}

