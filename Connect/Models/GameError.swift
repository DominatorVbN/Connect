//
//  GameError.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation

/// Thrown when an illegal move was attempted, e.g. storing a move in a field that already has a move assigned to it.
public struct IllegalMoveError: Error {
    let move: GameMove
}


public struct IllegalPlayerError: Error {
    let playerIndex: Int
}
