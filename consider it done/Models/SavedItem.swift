//
//  SavedItem.swift
//  consider it done
//

import Foundation
import SwiftData

enum SaveSource: String, CaseIterable, Codable {
    case instagram
    case youtube
    case reddit
    case facebook
    case twitter
    case other
}

@Model
final class SavedItem {
    @Attribute(.unique) var id: UUID
    var sourceURL: URL
    var sourceRawValue: String
    var title: String
    var itemDescription: String?
    var thumbnailURL: URL?
    var thumbnailData: Data?
    /// User-chosen image; takes priority over the Open Graph `thumbnailData`.
    @Attribute(.externalStorage) var customImageData: Data? = nil
    var savedAt: Date
    var archivedAt: Date?
    var reminderDate: Date?
    var viewedAt: Date?
    var isPinned: Bool
    @Relationship(deleteRule: .nullify) var collections: [Collection] = []
    @Relationship(deleteRule: .nullify) var tags: [Tag] = []

    /// The image to show: the user's custom image, else the Open Graph image.
    var displayImageData: Data? {
        customImageData ?? thumbnailData
    }

    var source: SaveSource {
        get { SaveSource(rawValue: sourceRawValue) ?? .other }
        set { sourceRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        sourceURL: URL,
        source: SaveSource,
        title: String,
        description: String? = nil,
        thumbnailURL: URL? = nil,
        thumbnailData: Data? = nil,
        savedAt: Date = Date(),
        archivedAt: Date? = nil,
        reminderDate: Date? = nil,
        viewedAt: Date? = nil,
        isPinned: Bool = false,
        collections: [Collection] = [],
        tags: [Tag] = []
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.sourceRawValue = source.rawValue
        self.title = title
        self.itemDescription = description
        self.thumbnailURL = thumbnailURL
        self.thumbnailData = thumbnailData
        self.savedAt = savedAt
        self.archivedAt = archivedAt
        self.reminderDate = reminderDate
        self.viewedAt = viewedAt
        self.isPinned = isPinned
        self.collections = collections
        self.tags = tags
    }
}

extension SavedItem {
    static func make(from url: URL, metadata: LinkMetadata) -> SavedItem {
        let tags = metadata.tags.map { Tag(name: $0) }

        return SavedItem(
            sourceURL: url,
            source: metadata.source,
            title: metadata.title,
            description: metadata.description,
            thumbnailURL: metadata.thumbnailURL,
            thumbnailData: metadata.thumbnailData,
            viewedAt: nil,
            isPinned: false,
            collections: [],
            tags: tags
        )
    }
}
