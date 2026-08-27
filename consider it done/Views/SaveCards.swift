//
//  SaveCards.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI
import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SaveGridCard: View {
    let save: SavedItem
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SaveThumbnail(data: save.thumbnailData)
                .frame(width: 120)
            SaveSourceMark(source: save.source)

            Text(save.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.figTextPrimary)
                .lineLimit(save.source == .other ? 3 : 2)

            if let description = save.itemDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(Color.figTextSoft)
                    .lineLimit(3)
            }

            SaveTagRow(tags: save.tags)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.figSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .matchedGeometryEffect(id: save.id, in: namespace)
    }
}

struct SaveListCard: View {
    let save: SavedItem
    let namespace: Namespace.ID

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            SaveThumbnail(data: save.thumbnailData)
            SaveSourceMark(source: save.source)

            VStack(alignment: .leading, spacing: 8) {
                Text(save.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.figTextPrimary)
                    .lineLimit(2)

                Text(save.sourceURL.absoluteString)
                    .font(.callout)
                    .foregroundStyle(Color.figTextSoft)
                    .lineLimit(1)

                SaveTagRow(tags: save.tags)
            }

            Spacer(minLength: 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.figSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .matchedGeometryEffect(id: save.id, in: namespace)
    }
}

struct SourceStackCard: View {
    let source: SaveSource
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let onSelect: (SavedItem) -> Void

    var body: some View {
        Button {
            if let firstSave = saves.first {
                onSelect(firstSave)
            }
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.figSurfaceMuted)
                    .offset(x: 8, y: 8)

                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.figSurfaceSoft)
                    .offset(x: 4, y: 4)

                VStack(alignment: .leading, spacing: 16) {
                    if let thumbnailData = saves.first?.thumbnailData {
                        SaveThumbnail(data: thumbnailData)
                            .frame(height: 72)
                    }

                    SaveSourceMark(source: source)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.displayName)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.figTextPrimary)

                        Text("\(saves.count) saved")
                            .font(.footnote)
                            .foregroundStyle(Color.figTextSoft)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
                .background(Color.figSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .buttonStyle(.plain)
        .matchedGeometryEffect(id: "source-\(source.rawValue)", in: namespace)
    }
}

struct SaveSourceMark: View {
    let source: SaveSource

    var body: some View {
        Text(source.shortName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.figTextPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.figSurfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

struct SaveTagRow: View {
    let tags: [Tag]

    var body: some View {
        if !tags.isEmpty {
            HStack(spacing: 8) {
                ForEach(tags.prefix(3)) { tag in
                    Text(tag.name)
                        .font(.caption)
                        .foregroundStyle(Color.figTextMuted)
                }
            }
        }
    }
}

extension SaveSource {
    var displayName: String {
        switch self {
        case .instagram:
            "Instagram"
        case .youtube:
            "YouTube"
        case .reddit:
            "Reddit"
        case .facebook:
            "Facebook"
        case .other:
            "Other"
        }
    }

    var shortName: String {
        switch self {
        case .instagram:
            "IG"
        case .youtube:
            "YT"
        case .reddit:
            "RD"
        case .facebook:
            "FB"
        case .other:
            "WEB"
        }
    }
}

struct SaveThumbnail: View {
    let data: Data?

    var body: some View {
        if let image = platformImage {
            imageView(image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(imageAspectRatio, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Color.figSurfaceMuted
                .frame(maxWidth: .infinity)
                .aspectRatio(1.5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }

    private var imageAspectRatio: CGFloat {
        guard let image = platformImage, image.size.height > 0 else { return 1.5 }
        return image.size.width / image.size.height
    }

#if os(iOS)
    private var platformImage: UIImage? { data.flatMap(UIImage.init(data:)) }
    private func imageView(_ image: UIImage) -> Image { Image(uiImage: image) }
#elseif os(macOS)
    private var platformImage: NSImage? { data.flatMap(NSImage.init(data:)) }
    private func imageView(_ image: NSImage) -> Image { Image(nsImage: image) }
#endif
}
