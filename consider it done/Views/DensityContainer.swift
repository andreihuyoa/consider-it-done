//
//  DensityContainer.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct DensityContainer: View {
    let density: BrowseDensity
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let onSelect: (SavedItem) -> Void

    var body: some View {
        switch density {
        case .organization:
            OrganizationGrid(saves: saves, namespace: namespace, onSelect: onSelect)
        case .grid:
            MasonryLayout(columns: 2, spacing: 12) {
                ForEach(saves) { save in
                    SaveGridCard(save: save, namespace: namespace)
                        .onTapGesture { onSelect(save) }
                }
            }
        case .list:
            LazyVStack(spacing: 8) {
                ForEach(saves) { save in
                    SaveListCard(save: save, namespace: namespace)
                        .onTapGesture { onSelect(save) }
                }
            }
        }
    }
}

struct OrganizationGrid: View {
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let onSelect: (SavedItem) -> Void

    private var groupedSaves: [(SaveSource, [SavedItem])] {
        SaveSource.allCases.compactMap { source in
            let sourceSaves = saves.filter { $0.source == source }
            return sourceSaves.isEmpty ? nil : (source, sourceSaves)
        }
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 12)], spacing: 12) {
            ForEach(groupedSaves, id: \.0) { source, sourceSaves in
                SourceStackCard(source: source, saves: sourceSaves, namespace: namespace, onSelect: onSelect)
            }
        }
    }
}

struct MasonryLayout: Layout {
    let columns: Int
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 360
        let columnWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let heights = columnHeights(for: subviews, columnWidth: columnWidth)

        return CGSize(width: width, height: (heights.max() ?? 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnWidth = (bounds.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var heights = Array(repeating: bounds.minY, count: columns)

        for subview in subviews {
            let column = heights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let x = bounds.minX + CGFloat(column) * (columnWidth + spacing)
            let y = heights[column]
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(width: columnWidth, height: size.height)
            )

            heights[column] += size.height + spacing
        }
    }

    private func columnHeights(for subviews: Subviews, columnWidth: CGFloat) -> [CGFloat] {
        var heights = Array(repeating: CGFloat.zero, count: columns)

        for subview in subviews {
            let column = heights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            heights[column] += size.height + spacing
        }

        return heights.map { max(0, $0 - spacing) }
    }
}
