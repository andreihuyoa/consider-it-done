//
//  CollectionsOverview.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct CollectionsOverview: View {
    let saves: [SavedItem]

    private var sourceGroups: [(SaveSource, [SavedItem])] {
        SaveSource.allCases.compactMap { source in
            let matchingSaves = saves.filter { $0.source == source }
            return matchingSaves.isEmpty ? nil : (source, matchingSaves)
        }
    }

    var body: some View {
        if sourceGroups.isEmpty {
            EmptyFigState(selectedArea: .collections)
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 16)], spacing: 16) {
                    ForEach(sourceGroups, id: \.0) { source, sourceSaves in
                        CollectionObjectCard(source: source, saves: sourceSaves)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct CollectionObjectCard: View {
    let source: SaveSource
    let saves: [SavedItem]

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.figSurfaceMuted)
                .offset(x: 12, y: 12)

            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.figSurfaceSoft)
                .offset(x: 6, y: 6)

            VStack(alignment: .leading, spacing: 20) {
                SaveSourceMark(source: source)

                VStack(alignment: .leading, spacing: 8) {
                    Text(source.displayName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.figTextPrimary)

                    Text("\(saves.count) links")
                        .font(.callout)
                        .foregroundStyle(Color.figTextSoft)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
            .background(Color.figSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(.trailing, 12)
        .padding(.bottom, 12)
    }
}
