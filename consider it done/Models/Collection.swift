//
//  Collection.swift
//  consider it done
//

import Foundation
import SwiftData

@Model
final class Collection {
    @Attribute(.unique) var id: UUID
    var name: String
    var coverThumbnailData: Data?

    init(id: UUID = UUID(), name: String, coverThumbnailData: Data? = nil) {
        self.id = id
        self.name = name
        self.coverThumbnailData = coverThumbnailData
    }
}
