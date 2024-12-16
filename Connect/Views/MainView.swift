//
//  LobbyView.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import SwiftUI

struct MainView: View {
    
    enum Destination: Hashable {
        case game(playerName: String)
    }
    
    @State var playerName: String = ""
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Text("Connect")
                    .font(.largeTitle)
                    .bold()
                    .fontDesign(.rounded)
                TextField("Player name", text: $playerName)
                    .textFieldStyle(.plain)
                    .font(.title)
                    .bold()
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(
                        Capsule()
                            .fill(.quaternary)
                    )
                Button {
                    path.append(Destination.game(playerName: playerName))
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 54))
                        .fontWeight(.bold)
                }
                .foregroundStyle(.blue)
                .buttonStyle(.plain)
                .disabled(playerName.isEmpty)
            }
            .navigationDestination(for: Destination.self) { type in
                switch type {
                case .game(let playerName):
                    GameView(playerName: playerName)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MainView()
}
