//
//  BoxView.swift
//  Connect
//
//  Created by Amit Samant on 06/12/24.
//

import Foundation
import SwiftUI

struct BoxView: View {
    @Environment(\.colorScheme) var colorScheme
    let box: Box
    var body: some View {
        switch box.type {
        case .empty:
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary)
        case .filled(let byPlayerID):
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.pastelColor(for: byPlayerID, in: colorScheme))
        }
       
    }
}


#Preview {
    BoxView(box: Box(top: 0, right: 5, bottom: 9, left: 2, type: .empty))
        .frame(width: 45, height: 45)
    BoxView(box: Box(top: 0, right: 5, bottom: 9, left: 2, type: .filled(byPlayerID: UUID())))
        .frame(width: 45, height: 45)
}
