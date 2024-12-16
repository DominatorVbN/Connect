//
//  LineView.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import SwiftUI
import ActorSystem

struct LineView: View {
    @Environment(\.colorScheme) var colorScheme
    let line: Line
    let onSelect: () async throws -> Void
    var body: some View {
        if case let .selected(playerId) = line.type {
            Capsule()
                .fill(Color.pastelColor(for: UUID(uuidString: playerId.id) ?? UUID(), in: colorScheme))
                .frame(width: 40, height: 4)
        } else {
            Button {
                Task { @MainActor in
                    try await onSelect()
                }
            } label: {
                Capsule()
                    .inset(by: 0.5)
                    .fill(.quaternary)
                    .stroke(Color.blue.opacity(0.1), style: .init(lineWidth: 1))
                    .frame(width: 40, height: 4)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    LineView(line: Line(
        endpoint1: Dot(indexPath: IndexPath(row: 0, section: 0)),
        endpoint2: Dot(indexPath: IndexPath(row: 0, section: 1)),
        type: .empty
    )) {
        
    }
    
    LineView(line: Line(
        endpoint1: Dot(indexPath: IndexPath(row: 0, section: 0)),
        endpoint2: Dot(indexPath: IndexPath(row: 0, section: 1)),
        type: .selected(byPlayerID: ActorIdentity.random)
    )) {
        
    }

}
