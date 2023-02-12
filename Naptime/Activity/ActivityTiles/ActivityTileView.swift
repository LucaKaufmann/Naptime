//
//  ActivityTileView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 10.2.2023.
//

import SwiftUI

struct ActivityTileView: View {
    
    let tile: ActivityTile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(tile.title)
                .font(.body)
            Text(tile.subtitle)
                .font(.subheadline)
            Spacer()
        }
        .foregroundColor(Color("ocean"))
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).foregroundColor(Color("slateLight"))
        )
    }
}

struct ActivityTileView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityTileView(tile: ActivityTile(id: UUID(), title: "Asleep today", subtitle: "12h 13min"))
    }
}
