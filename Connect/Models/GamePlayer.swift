//
//  GamePlayer.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation
import Distributed
import ActorSystem

public typealias MyPlayer = DistributedPlayer
public typealias OpponentPlayer = DistributedPlayer

public protocol GamePlayer: DistributedActor, Codable where ID == ActorIdentity {

    /// Ask this player to make a move of their own.
    func makeMove() async throws -> GameMove
    
    /// Inform this player their opponent has made the passed `move`.
    func opponentMoved(_ move: GameMove) async throws
    
    func getName() async throws -> String
}

public distributed actor DistributedPlayer: GamePlayer {
    
    
    public typealias ActorSystem = LocalNetworkActorSystem
    
    let name: String
    let model: GameViewModel
    let creationDate: Date
    var movesMade: Int = 0
    
    public init(name: String, model: GameViewModel, actorSystem: ActorSystem) {
        self.name = name
        self.model = model
        self.actorSystem = actorSystem
        self.creationDate = Date()
    }
    
    public distributed func makeMove() async throws -> GameMove {
        let selection = await model.humanSelectedField()
        movesMade += 1
        let move = GameMove(
            playerID: self.id,
            selection: selection
        )
        return move
    }
    
    public distributed func makeMove(_ selection: Selection) async throws -> GameMove {
        let move = GameMove(playerID: id, selection: selection)
        _ = await model.userMadeMove(move: move)
        movesMade += 1
        return move
    }
    
    public distributed func opponentMoved(_ move: GameMove) async throws {
        do {
            try await model.markOpponentMove(move)
        } catch {
            print("player", "Opponent made illegal move! \(move)")
        }
    }

    public distributed func startGameWith(opponent: OpponentPlayer, startTurn: Bool) async {
        print("local-network-player", "Start game with \(opponent.id), startTurn:\(startTurn)")
        await model.foundOpponent(opponent, myself: self, informOpponent: false)

        print("local-network-player", "Wait for opponent move: self id: \(self.id)")
        print("local-network-player", "Wait for opponent move: self id hash: \(self.id.hashValue)")

        print("local-network-player", "Wait for opponent move: self id: \(opponent.id)")
        print("local-network-player", "Wait for opponent move: self id hash: \(opponent.id.hashValue)")

        print("local-network-player", "Wait for opponent move: \(self.id < opponent.id)")
        print("local-network-player", "Wait for opponent move: \(self.id.hashValue < opponent.id.hashValue)")
        // we use some arbitrary method to pick who goes first
        await model.waitForOpponentMove(shouldWaitForOpponentMove(myselfID: self.id, opponentID: opponent.id))
    }
    
    public distributed func getName() async -> String {
        return name
    }
}


func shouldWaitForOpponentMove(myselfID: ActorIdentity, opponentID: ActorIdentity) -> Bool {
    myselfID.hashValue < opponentID.hashValue
}
