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
            MasonryLayout(columns: masonryColumnCount, spacing: 12) {
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

    private var masonryColumnCount: Int {
#if os(macOS)
        3
#else
        2
#endif
    }
}

struct OrganizationGrid: View {
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let onSelect: (SavedItem) -> Void

    @State private var sort: OrganizationSort = .recent
    @State private var groupBySource = false

    private var groupedSaves: [(SaveSource, [SavedItem])] {
        SaveSource.allCases.compactMap { source in
            let sourceSaves = saves.filter { $0.source == source }
            return sourceSaves.isEmpty ? nil : (source, sourceSaves)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Menu {
                    ForEach(OrganizationSort.allCases) { option in
                        Button {
                            sort = option
                        } label: {
                            HStack {
                                if sort == option {
                                    Image(systemName: "checkmark")
                                }
                                Text(option.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .foregroundStyle(Color.figAccent)
                        Text(sort.rawValue)
                            .foregroundStyle(Color.figTextPrimary)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.figTextMuted)
                    }
                    .font(.callout.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Divider()
                    .frame(height: 28)

                Toggle("Group", isOn: $groupBySource)
                    .toggleStyle(.button)
                    .tint(.figAccent)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.figSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.figBorder, lineWidth: 1)
            }

            if groupBySource {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 12)], spacing: 12) {
                    ForEach(groupedSaves, id: \.0) { source, sourceSaves in
                        SourceStackCard(source: source, saves: sourceSaves, namespace: namespace, onSelect: onSelect)
                    }
                }
            } else {
                OrganizationTileLayout(saves: sortedSaves, namespace: namespace, onSelect: onSelect, sort: sort)
            }
        }
    }

    private var sortedSaves: [SavedItem] {
        switch sort {
        case .importance:
            saves.sorted {
                if $0.isPinned != $1.isPinned { return $0.isPinned }
                return $0.savedAt > $1.savedAt
            }
        case .recent:
            saves.sorted { $0.savedAt > $1.savedAt }
        case .reminder:
            saves.sorted { ($0.reminderDate ?? .distantFuture) < ($1.reminderDate ?? .distantFuture) }
        }
    }
}

enum OrganizationSort: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case importance = "Importance"
    case reminder = "Reminder"
    var id: String { rawValue }
}

struct OrganizationTileLayout: View {
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let onSelect: (SavedItem) -> Void
    let sort: OrganizationSort

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: 12)], spacing: 12) {
            ForEach(Array(saves.enumerated()), id: \.element.id) { index, save in
                Button { onSelect(save) } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        SaveSourceMark(source: save.source)
                        Text(save.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.figTextPrimary)
                            .lineLimit(tileLineLimit(for: save, index: index))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, minHeight: tileHeight(for: save, index: index), alignment: .topLeading)
                    .background(Color.figSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: save.id, in: namespace)
            }
        }
    }

    private func tileHeight(for save: SavedItem, index: Int) -> CGFloat {
        switch sort {
        case .importance:
            return save.isPinned ? 184 : 136
        case .recent:
            return index == 0 ? 184 : 136
        case .reminder:
            return save.reminderDate == nil ? 136 : 184
        }
    }

    private func tileLineLimit(for save: SavedItem, index: Int) -> Int {
        tileHeight(for: save, index: index) > 160 ? 4 : 2
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
