//
//  DotView.swift
//  Connect
//
//  Created by Amit Samant on 03/12/24.
//

import SwiftUI

struct DotView: View {
//    let dot: Dot
    var body: some View {
        Circle()
            .frame(width: 4, height: 4)
    }
}

#Preview {
    DotView(
//        dot: Dot(indexPath: IndexPath(row: 0, section: 0))
    )
}
