//
//  GameState.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import Foundation
import ActorSystem

struct GameState {
    
    let size = 4
    var dots: [Dot] = []
    var verticalLines: [Line] = []
    var horizontalLines: [Line] = []
    var lines: [Line]  {
        verticalLines + horizontalLines
    }
    var boxes: [Box] = []
    
    
    init() {
        for row in 0..<size {
            for col in 0..<size {
                dots.append(
                    Dot(
                        indexPath: IndexPath(
                            row: row,
                            section: col
                        )
                    )
                )
            }
        }
        
        for row in 0..<size {
            for col in 0..<size {
                let indexPath = IndexPath(row: row, section: col)
                if col < (size - 1) {
                    let rightIndexPath = IndexPath(row: row, section: col + 1)
                    let line = Line(
                        endpoint1: findDot(indexPath)!,
                        endpoint2: findDot(rightIndexPath)!,
                        type: .empty
                    )
                    self.horizontalLines.append(line)
                }
                if row < (size - 1) {
                    let bottomIndexPath = IndexPath(row: row + 1, section: col)
                    let line = Line(
                        endpoint1: findDot(indexPath)!,
                        endpoint2: findDot(bottomIndexPath)!,
                        type: .empty
                    )
                    self.verticalLines.append(line)
                }
            }
        }
        
        for row in 0..<(size-1) {
            for col in 0..<(size-1) {
                if row < (size - 1) && col < (size - 1) {
                    
                    let p1 = findDot(IndexPath(row: row, section: col))!
                    let p2 = findDot(IndexPath(row: row, section: col + 1))!
                    let p3 = findDot(IndexPath(row: row + 1, section: col + 1))!
                    let p4 = findDot(IndexPath(row: row + 1, section: col))!
                    
                    let top = self.findHorizontalLineIndex(p1, to: p2)!
                    let right = self.findVerticalLineIndex(p2, to: p3)!
                    let left = self.findVerticalLineIndex(p1, to: p4)!
                    let bottom = self.findHorizontalLineIndex(p4, to: p3)!
                    
                    
                    let box = Box(
                        top: top,
                        right: right,
                        bottom: bottom,
                        left: left,
                        type: .empty
                    )
                    print(box)
                    boxes.append(box)
                }
            }
        }
    }
    
    // Public interface
    public mutating func mark(_ move: GameMove) throws {
        // Validation and marking
        switch move.selection {
        case .horizontal(let index):
            try markHorizonatal(index, move: move)
        case .vertical(let index):
            try markVertical(index, move: move)
        }
    }
    
    public mutating func checkWin() throws -> GameResult? {
        var playerBoxCount: [UUID: Int] = [:]
        let allSatisfy = boxes.allSatisfy { box in
            guard case let .filled(playerId) = box.type else { return false }
            if let oldCount = playerBoxCount[playerId] {
                playerBoxCount[playerId] = oldCount + 1
            } else {
                playerBoxCount[playerId] = 1
            }
            return true
        }
        if allSatisfy {
            // Check for draw
            let maxBoxCount = playerBoxCount.max(by: { $0.value < $1.value })!.value
            let drawPlayers = playerBoxCount.filter { element in
                element.value == maxBoxCount
            }.map(\.key)
            if drawPlayers.count == 1 {
                let playerId = drawPlayers[0]
                return .win(player: playerId)
            } else {
                return .draw(players: drawPlayers)
            }
        } else {
            return nil
        }
    }

    private mutating func checkAndSetTypeOfCompletedBox(_ playerID: UUID, lineIndex: Int) {
        for (boxIndex, box) in boxes.enumerated() where box.type == .empty && box.contains(lineIndex: lineIndex) {
            let topLine = horizontalLines[box.top]
            let bottomLine = horizontalLines[box.bottom]
            let leftLine = verticalLines[box.left]
            let rightLine = verticalLines[box.right]
            let lines: [Line] = [topLine, bottomLine, leftLine, rightLine]
            let allSatisfy = lines.allSatisfy { line in
                line.type != .empty
            }
            if allSatisfy {
                print("Found box to fill with at index: \(boxIndex) box:\(box)")
                boxes[boxIndex].type = .filled(byPlayerID: playerID)
            }
        }
    }
    
    private mutating func markHorizonatal(_ index: Int, move: GameMove) throws {
        guard index >= 0, index < horizontalLines.count else {
            throw IllegalMoveError(move: move)
        }
        let line = horizontalLines[index]
        guard line.type == .empty else {
            throw IllegalMoveError(move: move)
        }
        horizontalLines[index].type = .selected(byPlayerID: move.playerID)
        checkAndSetTypeOfCompletedBox(move.playerID, lineIndex: index)
    }
    
    private mutating func markVertical(_ index: Int, move: GameMove) throws {
        guard index >= 0, index < verticalLines.count else {
            throw IllegalMoveError(move: move)
        }
        let line = verticalLines[index]
        guard line.type == .empty else {
            throw IllegalMoveError(move: move)
        }
        verticalLines[index].type = .selected(byPlayerID: move.playerID)
        checkAndSetTypeOfCompletedBox(move.playerID, lineIndex: index)
    }
    
    func findDot(_ indexPath: IndexPath) -> Dot? {
        dots.first(where: { $0.indexPath == indexPath })
    }
    
    func findVerticalLineIndex(_ endpoint1: Dot, to endpoint2: Dot) -> Int? {
        verticalLines.firstIndex(where: { $0.endpoint1 == endpoint1 && $0.endpoint2 == endpoint2 })
    }
    
    func findHorizontalLineIndex(_ endpoint1: Dot, to endpoint2: Dot) -> Int? {
        horizontalLines.firstIndex(where: { $0.endpoint1 == endpoint1 && $0.endpoint2 == endpoint2 })
    }
    
    func findLine(_ endpoint1: Dot, to endpoint2: Dot) -> Line? {
        lines.first(where: { $0.endpoint1 == endpoint1 && $0.endpoint2 == endpoint2 })
    }
    
}
