//
//  GameResult.swift
//  Connect
//
//  Created by Amit Samant on 06/12/24.
//

import Foundation
import ActorSystem

/// Result of a game round; A game can end in a draw or win of a specific player.
public enum GameResult: Equatable {
    case win(player: ActorIdentity)
    case draw(players: [ActorIdentity])
}
