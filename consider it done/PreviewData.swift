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
        let schema = Schema([SavedItem.self, Collection.self, Tag.self])
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
            .enumerated()
            .forEach { index, url in
                let source = LinkClassifier.classifySource(url)
                container.mainContext.insert(SavedItem(
                    sourceURL: url,
                    source: source,
                    title: url.host() ?? url.absoluteString,
                    savedAt: Date(timeIntervalSinceNow: TimeInterval(-index * 3600)),
                    isPinned: index == 0
                ))
            }

        return container
    }
}
