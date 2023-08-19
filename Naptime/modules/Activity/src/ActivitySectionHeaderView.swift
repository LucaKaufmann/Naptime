//
//  ActivitySectionHeaderView.swift
//  Naptime
//
//  Created by Luca Kaufmann on 7.12.2022.
//

import SwiftUI

struct ActivitySectionHeaderView: View {
    
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(date, style: .date)
                .fontWeight(.semibold)
            HStack {
                Spacer()
            }
        }.padding(.horizontal)
    }
}

struct ActivitySectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySectionHeaderView(date: Date())
    }
}
