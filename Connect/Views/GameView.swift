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
        self.player = .init(name: playerName, model: model, actorSystem: localNetworkSystem)
        localNetworkSystem.receptionist.checkIn(player, tag: "static")
        model.opponent = nil
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
            } else {
                matchMakingView
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
                    if let name = try await viewModel.names(forPlayerIds: [playerId]).first {
                        await MainActor.run {
                            gameResultMessage = "\(name) won!"
                            showingAlert = true
                        }
                    }
                }
            case .draw(let playerIds):
                Task {
                    let names = try await viewModel.names(forPlayerIds: playerIds).joined(separator: ", ")
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
            AvatarView(id: player.id.id, name: playerName, isOpponent: false, isOpponentTurn: viewModel.isGameDisabled)
            Text("vs")
                .bold()
            AvatarView(id: opponent.id.id, name: viewModel.oppponentName, isOpponent: true, isOpponentTurn: viewModel.isGameDisabled)
        }
    }
    
    var matchMakingView: some View {
        HStack {
            ProgressView()
                .padding(8)
                .background {
                    Capsule().fill(.quaternary)
                }
            Text("Looking for opponent 🔎")
                .font(.title2)
        }
        .padding(8)
        .background {
            Capsule().fill(.quaternary)
        }
        .task {
            await startMatchMaking()
        }
    }

}

// - MARK: Minimal logic helpers

extension GameView {

    /// Start match making by looking for a new opponent to play a game with.
    ///
    /// Note that this is a rather simple implementation, which does not take into account
    /// that the discovered player may already be playing a game, or verifying that they indeed are a
    /// player of the opposing team (we trust the receptionist to list the right opponents).
    func startMatchMaking() async {
        guard viewModel.opponent == nil else {
            return
        }
    
        /// The local network actor system provides a receptionist implementation that provides us an async sequence
        /// of discovered actors (past and new)
        let listing = await localNetworkSystem.receptionist.listing(of: DistubutedPlayer.self, tag: "static")
        for try await opponent in listing where opponent.id != self.player.id {
            print("matchmaking", "Found opponent: \(opponent)")
            viewModel.foundOpponent(opponent, myself: self.player, informOpponent: true)

            return // make sure to return here, we only need to discover a single opponent
        }
    }
    
}


#Preview {
    NavigationView {
        GameView(playerName: "Amit")
    }
}
