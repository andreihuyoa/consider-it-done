//
//  DensityControl.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct DensityControl: View {
    @Binding var density: BrowseDensity

    var body: some View {
        HStack(spacing: 8) {
            Text("Density")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.figTextSoft)

            Picker("Density", selection: $density) {
                Image(systemName: "square.grid.3x3").tag(BrowseDensity.organization)
                Image(systemName: "square.grid.2x2").tag(BrowseDensity.grid)
                Image(systemName: "list.bullet").tag(BrowseDensity.list)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)
            .tint(.figAccent)

            Spacer()
        }
    }
}
