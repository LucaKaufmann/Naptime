//
//  ActivityTileView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 10.2.2023.
//

import SwiftUI
import DesignSystem

struct ActivityTileView: View {
    
    let tile: ActivityTile
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(tile.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding(.bottom, 5)
            Spacer()
            Text(tile.subtitle)
                .font(.subheadline)
        }
        .foregroundColor(NaptimeDesignColors.slateDark)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12).foregroundColor(NaptimeDesignColors.sandLight)
        )
    }
}

struct ActivityTileView_Previews: PreviewProvider {
    
    static var previews: some View {
        LazyHStack(alignment: .center) {
            Group {
                ActivityTileView(tile: ActivityTile(id: UUID(), title: "Sleep today", subtitle: "12h 13min", type: .sleepToday))
            }
            .frame(width: 140, height: 100)
            Group {
                ActivityTileView(tile: ActivityTile(id: UUID(), title: "Naps today", subtitle: "12h 13min", type: .napsToday))
            }
            .frame(width: 140, height: 100)
        }
        .padding(.horizontal)

    }
}
