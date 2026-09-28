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
    @Environment(\.isEnabled) private var isEnabled
    let save: SavedItem
    let namespace: Namespace.ID
    let onSelect: () -> Void

    var body: some View {
        SaveCard(save: save, style: .compact, onSelect: onSelect)
            .matchedGeometryEffect(id: save.id, in: namespace, isSource: isEnabled)
    }
}

/// The save card from design.md → "Save card anatomy": media, title,
/// description, tags, divider, and a source footer with an Open Link button.
struct SaveCard: View {
    enum Style {
        case compact
        case hero
    }

    let save: SavedItem
    let style: Style
    let onSelect: () -> Void

    private var inset: CGFloat { style == .hero ? 20 : 16 }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero media flexes so every carousel card has the same size,
                // whatever the image's aspect ratio.
                SaveThumbnail(data: save.displayImageData, cornerRadius: 0, fillsAvailableHeight: style == .hero)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: style == .hero ? 12 : 8) {
                    Text(save.title)
                        .font(.heading(style == .hero ? .title2 : .headline))
                        .foregroundStyle(Color.figTextPrimary)
                        .lineLimit(style == .hero ? 3 : 2)
                        .fixedSize(horizontal: false, vertical: true)

                    if let description = save.itemDescription, !description.isEmpty {
                        Text(description)
                            .font(.text(style == .hero ? .body : .subheadline))
                            .foregroundStyle(Color.figTextSoft)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    SaveTagRow(tags: save.tags)

                    Rectangle()
                        .fill(Color.figBorder.opacity(0.25))
                        .frame(height: 1)
                        .padding(.top, 4)
                        .accessibilityHidden(true)

                    SaveSourceFooter(save: save, style: style)
                }
                .padding(inset)
                .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: style == .hero ? .infinity : nil, alignment: .top)
            .background(Color.figSurface)
            .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Opens saved link details")
        .overlay(alignment: .bottomTrailing) {
            SaveOpenLinkButton(url: save.sourceURL, diameter: style == .hero ? 40 : 36)
                .padding(inset)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .figShadow, radius: style == .hero ? 12 : 8, x: 0, y: style == .hero ? 4 : 3)
    }

    private var accessibilityLabel: String {
        [save.title, save.itemDescription, save.source.displayName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

/// The source pill. Reserves trailing room for the Open Link button that
/// `SaveCard` overlays on top of it.
struct SaveSourceFooter: View {
    let save: SavedItem
    let style: SaveCard.Style

    var body: some View {
        HStack(spacing: 8) {
            SaveSourcePill(source: save.source)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        }
    }
}

/// Where a save came from, as one accent capsule. Used on cards and in detail.
struct SaveSourcePill: View {
    let source: SaveSource

    var body: some View {
        Text(source.displayName)
            .font(.text(.footnote, weight: .semibold))
            .foregroundStyle(Color.figSurface)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.figAccent, in: Capsule())
    }
}

struct SaveOpenLinkButton: View {
    let url: URL
    let diameter: CGFloat

    var body: some View {
        Link(destination: url) {
            Image(systemName: "arrow.up.right")
                .font(.text(.callout, weight: .semibold))
                .foregroundStyle(Color.figTextPrimary)
                .frame(width: diameter, height: diameter)
                .background(Color.figSurfaceMuted, in: Circle())
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open Link")
    }
}

struct SaveListCard: View {
    @Environment(\.isEnabled) private var isEnabled
    let save: SavedItem
    let namespace: Namespace.ID

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            SaveThumbnail(data: save.displayImageData)
            SaveSourcePill(source: save.source)

            VStack(alignment: .leading, spacing: 8) {
                Text(save.title)
                    .font(.heading(.headline))
                    .foregroundStyle(Color.figTextPrimary)
                    .lineLimit(2)

                Text(save.sourceURL.absoluteString)
                    .font(.text(.callout))
                    .foregroundStyle(Color.figTextSoft)
                    .lineLimit(1)

                SaveTagRow(tags: save.tags)
            }

            Spacer(minLength: 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.figSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .figShadow, radius: 8, x: 0, y: 3)
        .matchedGeometryEffect(id: save.id, in: namespace, isSource: isEnabled)
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
                    if let thumbnailData = saves.first?.displayImageData {
                        SaveThumbnail(data: thumbnailData)
                            .frame(height: 72)
                    }

                    SaveSourcePill(source: source)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(source.displayName)
                            .font(.heading(.headline))
                            .foregroundStyle(Color.figTextPrimary)

                        Text("\(saves.count) saved")
                            .font(.text(.footnote))
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

struct SaveTagRow: View {
    let tags: [Tag]

    var body: some View {
        if !tags.isEmpty {
            HStack(spacing: 8) {
                ForEach(tags.prefix(3)) { tag in
                    Text(tag.name)
                        .font(.text(.caption))
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
        case .twitter:
            "X"
        case .other:
            "Web"
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
        case .twitter:
            "X"
        case .other:
            "WEB"
        }
    }
}

struct SaveThumbnail: View {
    let data: Data?
    var cornerRadius: CGFloat = 8
    /// When set, the media fills this height instead of following the image's aspect ratio.
    var fixedHeight: CGFloat? = nil
    /// When true, the media takes whatever height its container leaves and crops to fill.
    var fillsAvailableHeight = false

#if os(iOS)
    private static let imageCache = NSCache<NSData, UIImage>()
#elseif os(macOS)
    private static let imageCache = NSCache<NSData, NSImage>()
#endif

    var body: some View {
        if fillsAvailableHeight {
            Color.figSurfaceMuted
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: .infinity)
                .overlay {
                    if let image = platformImage {
                        imageView(image)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else if let fixedHeight {
            Color.figSurfaceMuted
                .frame(maxWidth: .infinity)
                .frame(height: fixedHeight)
                .overlay {
                    if let image = platformImage {
                        imageView(image)
                            .resizable()
                            .scaledToFill()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else if let image = platformImage {
            Color.clear
                .aspectRatio(imageAspectRatio(for: image), contentMode: .fit)
                .frame(maxWidth: .infinity)
                .overlay {
                    imageView(image)
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            Color.figSurfaceMuted
                .frame(maxWidth: .infinity)
                .aspectRatio(1.5, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    private func imageAspectRatio(for image: PlatformImage) -> CGFloat {
        guard image.size.height > 0 else { return 1.5 }
        // Clamp very tall or very wide images so a card's media stays predictable.
        return min(max(image.size.width / image.size.height, 0.75), 2)
    }

#if os(iOS)
    private typealias PlatformImage = UIImage

    private var platformImage: UIImage? {
        cachedImage(using: UIImage.init(data:))
    }

    private func imageView(_ image: UIImage) -> Image { Image(uiImage: image) }
#elseif os(macOS)
    private typealias PlatformImage = NSImage

    private var platformImage: NSImage? {
        cachedImage(using: NSImage.init(data:))
    }

    private func imageView(_ image: NSImage) -> Image { Image(nsImage: image) }
#endif

    private func cachedImage(using decode: (Data) -> PlatformImage?) -> PlatformImage? {
        guard let data else { return nil }
        let key = data as NSData
        if let cachedImage = Self.imageCache.object(forKey: key) {
            return cachedImage
        }
        guard let image = decode(data) else { return nil }
        Self.imageCache.setObject(image, forKey: key)
        return image
    }
}
