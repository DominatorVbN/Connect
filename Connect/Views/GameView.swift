//
//  ContentView.swift
//  Connect
//
//  Created by Amit Samant on 25/11/24.
//

import SwiftUI

struct GameView: View {
    let player: MyPlayer
    let playerName: String
    @StateObject var viewModel: GameViewModel
    
    init(playerName: String) {
        let model = GameViewModel()
        self._viewModel = .init(wrappedValue: model)
        self.playerName = playerName
        self.player = .init(name: playerName, model: model)
//        localNetworkSystem.receptionist.checkIn(player, tag: "static")
        model.player = player
        model.opponent = BotPlayer()
    }
    
    let lineLenght: CGFloat = 44
    
    @State private var verticalSelectedIndexPath: Set<IndexPath> = []
    @State private var horizontalSelectedIndexPath: Set<IndexPath> = []
    @State private var showingAlert = false
    @State private var gameResultMessage: String = ""
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            if let opponent = viewModel.opponent {
                opponentView(opponent: opponent)
            } 
            
            Divider()
                .padding(44)
            
            ZStack {
                
                Grid(alignment: .center, horizontalSpacing: 44, verticalSpacing: 44) {
                    ForEach(0..<viewModel.size, id: \.self) { row in
                        GridRow {
                            ForEach(0..<viewModel.size, id: \.self) { col in
                                DotView()
                            }
                        }
                    }
                }
                
                Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 44) {
                    ForEach(0..<viewModel.size, id: \.self) { row in
                        GridRow {
                            ForEach(0..<(viewModel.size-1), id: \.self) { col in
                                LineView(
                                    line: viewModel.horizontalLine(at: IndexPath(row: row, section: col))!
                                ) {
                                    let indexPath = IndexPath(row: row, section: col)
                                    let index = viewModel.getHorizontalIndex(at: indexPath)
                                    _ = try await player.makeMove(.horizontal(index: index))
                                }
                                .disabled(viewModel.isGameDisabled)
                            }
                        }
                    }
                }
                
                Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 44) {
                    ForEach(0..<viewModel.size, id: \.self) { row in
                        GridRow {
                            ForEach(0..<(viewModel.size-1), id: \.self) { col in
                                LineView(
                                    line: viewModel.verticalLine(at: IndexPath(row: row, section: col))!
                                ) {
                                    let indexPath = IndexPath(row: row, section: col)
                                    let index = viewModel.getVerticalIndex(at: indexPath)
                                    _ = try await player.makeMove(.vertical(index: index))
                                }
                                .disabled(viewModel.isGameDisabled)
                            }
                        }
                    }
                }.rotationEffect(.degrees(90))
                
                Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 8) {
                    ForEach(0..<(viewModel.size-1), id: \.self) { row in
                        GridRow {
                            ForEach(0..<(viewModel.size-1), id: \.self) { col in
                                BoxView(
                                    box: viewModel.getBox(at: IndexPath(row: row, section: col))
                                )
                                .frame(width: 40, height: 40)
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .alert(gameResultMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
        .onChange(of: viewModel.gameResult) { _, newValue in
            guard let newValue else { return }
            switch newValue {
            case .win(let playerId):
                Task {
                    if let name = viewModel.names(forPlayerIds: [playerId]).first {
                        await MainActor.run {
                            gameResultMessage = "\(name) won!"
                            showingAlert = true
                        }
                    }
                }
            case .draw(let playerIds):
                Task {
                    let names = viewModel.names(forPlayerIds: playerIds).joined(separator: ", ")
                    await MainActor.run {
                        gameResultMessage = "Draw between \(names)!"
                        showingAlert = true
                    }
                }
            }
        }
        .navigationTitle("Connect")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func opponentView(opponent: any GamePlayer) -> some View {
        HStack {
            AvatarView(id: player.id.uuidString, name: playerName, isOpponent: false, isOpponentTurn: viewModel.isGameDisabled)
            Text("vs")
                .bold()
            AvatarView(id: opponent.id.uuidString, name: opponent.name, isOpponent: true, isOpponentTurn: viewModel.isGameDisabled)
        }
    }

}


#Preview {
    NavigationView {
        GameView(playerName: "Amit")
    }
}
