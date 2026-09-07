//
//  DensityControl.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct DensityControl: View {
    @Binding var density: BrowseDensity

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                densityLabel
                densityMenu
            }
        } else {
            HStack(spacing: 8) {
                densityLabel
                densityPicker
                Spacer()
            }
        }
    }

    private var densityLabel: some View {
        Text("Density")
            .font(.footnote.weight(.medium))
            .foregroundStyle(Color.figTextSoft)
    }

    private var densityPicker: some View {
        Picker("Density", selection: $density) {
            ForEach(BrowseDensity.allCases, id: \.self) { option in
                Label(option.title, systemImage: option.symbol)
                    .tag(option)
            }
        }
        .pickerStyle(.segmented)
        .frame(maxWidth: 260)
        .tint(.figAccent)
    }

    private var densityMenu: some View {
        Menu {
            Picker("Density", selection: $density) {
                ForEach(BrowseDensity.allCases, id: \.self) { option in
                    Label(option.title, systemImage: option.symbol)
                        .tag(option)
                }
            }
        } label: {
            Label("Density: \(density.title)", systemImage: density.symbol)
                .font(.body)
                .foregroundStyle(Color.figTextPrimary)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .padding(.horizontal, 16)
                .background(Color.figSurface, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

private extension BrowseDensity {
    var title: String {
        switch self {
        case .organization: "Organization"
        case .grid: "Masonry"
        case .list: "Carousel"
        }
    }

    var symbol: String {
        switch self {
        case .organization: "square.grid.3x3"
        case .grid: "square.grid.2x2"
        case .list: "rectangle.stack"
        }
    }
}
