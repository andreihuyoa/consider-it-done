//
//  CollectionsOverview.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct CollectionsOverview: View {
    let saves: [SavedItem]

    private var collections: [Collection] {
        var seen = Set<UUID>()
        return saves
            .flatMap(\.collections)
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        if collections.isEmpty {
            EmptyFigState(selectedArea: .collections)
        } else {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: 16)], spacing: 16) {
                    ForEach(collections) { collection in
                        CollectionObjectCard(collection: collection, saves: saves.filter { $0.collections.contains(where: { $0.id == collection.id }) })
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct CollectionObjectCard: View {
    let collection: Collection
    let saves: [SavedItem]

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.figSurfaceMuted)
                .offset(x: 12, y: 12)

            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.figSurfaceSoft)
                .offset(x: 6, y: 6)

            VStack(alignment: .leading, spacing: 20) {
                if let thumbnailData = collection.coverThumbnailData {
                    SaveThumbnail(data: thumbnailData)
                        .frame(height: 72)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(collection.name)
                        .font(.heading(.title3))
                        .foregroundStyle(Color.figTextPrimary)

                    Text("\(saves.count) links")
                        .font(.text(.callout))
                        .foregroundStyle(Color.figTextSoft)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
            .background(Color.figSurface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.trailing, 12)
        .padding(.bottom, 12)
    }
}
