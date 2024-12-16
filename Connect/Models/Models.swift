//
//  Models.swift
//  Connect
//
//  Created by Amit Samant on 28/11/24.
//

import Foundation
import ActorSystem

struct Dot: Equatable {
    let indexPath: IndexPath
}

enum Player: Equatable {
    case player
}

enum LineType: Equatable {
    case empty
    case selected(byPlayerID: UUID)
}

struct Line: Equatable {
    
    let endpoint1: Dot
    let endpoint2: Dot
    var type: LineType
    
    init(endpoint1: Dot, endpoint2: Dot, type: LineType) {
        self.endpoint1 = endpoint1
        self.endpoint2 = endpoint2
        self.type = type
    }
    
}

enum BoxType: Equatable {
    case empty
    case filled(byPlayerID: UUID)
}

struct Box {
    let top: Int
    let right: Int
    let bottom: Int
    let left: Int
    var type: BoxType
    
    init(top: Int, right: Int, bottom: Int, left: Int, type: BoxType) {
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.type = type
    }
    
    func contains(lineIndex: Int) -> Bool {
        [top, right, bottom, left].contains(lineIndex)
    }
}
