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
                Label("Organization", systemImage: "square.grid.3x3").tag(BrowseDensity.organization)
                Label("Masonry", systemImage: "square.grid.2x2").tag(BrowseDensity.grid)
                Label("Carousel", systemImage: "rectangle.stack").tag(BrowseDensity.list)
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 260)
            .tint(.figAccent)

            Spacer()
        }
    }
}
