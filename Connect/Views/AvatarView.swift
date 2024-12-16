//
//  OpponentView.swift
//  Connect
//
//  Created by Amit Samant on 16/12/24.
//

import SwiftUI

struct AvatarView: View {
    
    let id: UUID
    let name: String?
    let isOpponent: Bool
    let isOpponentTurn: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    init(id: String, name: String?, isOpponent: Bool, isOpponentTurn: Bool) {
        self.id = UUID.init(uuidString: id) ?? UUID()
        self.name = name
        self.isOpponent = isOpponent
        self.isOpponentTurn = isOpponentTurn
    }
    
    var avatarView: some View {
        Text(nameOrIdInitial)
            .font(.title2)
            .bold()
            .foregroundStyle(.background)
            .frame(width: 44, height: 44)
            .background {
                Circle()
                    .fill(
                        Color
                            .pastelColor(
                                for: id,
                                in: colorScheme
                            )
                            .gradient
                    )
            }
        
    }
    
    var body: some View {
        VStack {
            Text( isOpponent ? "Opponent" : "You")
            HStack {
                avatarView
                Text(nameOrId)
                    .font(.title2)
                    .bold()
                    .fontDesign(.rounded)
                    .padding(.trailing)
                    .lineLimit(1)
            }
            .padding(8)
            .background {
                Capsule().fill(.quaternary)
            }
            
            if isOpponent {
                oppnentTurnView
            } else {
                playerTurnView
            }
            
        }
    }
    
    @ViewBuilder
    var playerTurnView: some View {
        if !isOpponentTurn {
            HStack {
                Text("Your turn")
            }
        } else {
            HStack {
                Text("Your turn")
            }
            .hidden()
        }
    }
    
    @ViewBuilder
    var oppnentTurnView: some View {
        if isOpponentTurn {
            HStack {
                Text("\(nameOrId)'s turn")
                ProgressView()
            }
        } else {
            HStack {
                Text("\(nameOrId)'s turn")
                ProgressView()
            }
            .hidden()
        }
    }
    
    var nameOrId: String {
        name ?? id.uuidString
    }
    
    var nameOrIdInitial: String {
        if nameOrId.isEmpty {
            return String(id.uuidString.first!).uppercased()
        } else {
            return String(nameOrId.first!).uppercased()
        }
    }
}

#Preview {
    AvatarView(id: UUID().uuidString, name: nil, isOpponent: true, isOpponentTurn: false)
    AvatarView(id: UUID().uuidString, name: "Amit", isOpponent: true, isOpponentTurn: true)
    AvatarView(id: UUID().uuidString, name: nil, isOpponent: false, isOpponentTurn: true)
    AvatarView(id: UUID().uuidString, name: "Nalin", isOpponent: false, isOpponentTurn: false)
}
