//
//  PreviewData.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import Foundation
import SwiftData

enum PreviewData {
    @MainActor
    static var container: ModelContainer {
        let schema = Schema([SavedItem.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])

        [
            "https://www.instagram.com/reel/example",
            "https://www.youtube.com/watch?v=example",
            "https://www.reddit.com/r/swift/comments/example",
            "https://developer.apple.com/design/human-interface-guidelines",
            "https://www.instagram.com/p/example",
            "https://youtu.be/example"
        ]
            .compactMap(URL.init(string:))
            .map(SavedItem.make(from:))
            .forEach { container.mainContext.insert($0) }

        return container
    }
}
