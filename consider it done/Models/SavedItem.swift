//
//  SavedItem.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import Foundation
import SwiftData

enum SaveSource: String, CaseIterable, Codable {
    case instagram
    case youtube
    case reddit
    case website
}

enum SaveContentType: String, CaseIterable, Codable {
    case instagramPost
    case instagramReel
    case youtubeVideo
    case redditPost
    case webpage
}

enum SaveStatus: String, CaseIterable, Codable {
    case inbox
    case saved
    case archived
}

@Model
final class SavedItem {
    @Attribute(.unique) var id: UUID
    var sourceURL: URL
    var sourceRawValue: String
    var contentTypeRawValue: String
    var title: String
    var itemDescription: String?
    var thumbnailURL: URL?
    var creator: String?
    var createdAt: Date?
    var savedAt: Date
    var collectionIDs: [UUID]
    var tags: [String]
    var statusRawValue: String

    var source: SaveSource {
        get { SaveSource(rawValue: sourceRawValue) ?? .website }
        set { sourceRawValue = newValue.rawValue }
    }

    var contentType: SaveContentType {
        get { SaveContentType(rawValue: contentTypeRawValue) ?? .webpage }
        set { contentTypeRawValue = newValue.rawValue }
    }

    var status: SaveStatus {
        get { SaveStatus(rawValue: statusRawValue) ?? .inbox }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        sourceURL: URL,
        source: SaveSource,
        contentType: SaveContentType,
        title: String,
        description: String? = nil,
        thumbnailURL: URL? = nil,
        creator: String? = nil,
        createdAt: Date? = nil,
        savedAt: Date = Date(),
        collectionIDs: [UUID] = [],
        tags: [String] = [],
        status: SaveStatus = .inbox
    ) {
        self.id = id
        self.sourceURL = sourceURL
        self.sourceRawValue = source.rawValue
        self.contentTypeRawValue = contentType.rawValue
        self.title = title
        self.itemDescription = description
        self.thumbnailURL = thumbnailURL
        self.creator = creator
        self.createdAt = createdAt
        self.savedAt = savedAt
        self.collectionIDs = collectionIDs
        self.tags = tags
        self.statusRawValue = status.rawValue
    }
}

extension SavedItem {
    static func make(from url: URL) -> SavedItem {
        let metadata = LinkClassifier.classify(url)

        return SavedItem(
            sourceURL: url,
            source: metadata.source,
            contentType: metadata.contentType,
            title: metadata.title,
            description: metadata.description,
            creator: metadata.creator,
            tags: metadata.tags,
            status: .inbox
        )
    }
}
