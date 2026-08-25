//
//  LinkClassifier.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import Foundation

struct LinkMetadata {
    let source: SaveSource
    let contentType: SaveContentType
    let title: String
    let description: String?
    let creator: String?
    let tags: [String]
}

enum LinkClassifier {
    static func classify(_ url: URL) -> LinkMetadata {
        let host = (url.host(percentEncoded: false) ?? "").lowercased()
        let path = url.path(percentEncoded: false).lowercased()
        let displayTitle = title(for: url)

        if host.contains("instagram.com") {
            let isReel = path.contains("/reel/")
            return LinkMetadata(
                source: .instagram,
                contentType: isReel ? .instagramReel : .instagramPost,
                title: displayTitle,
                description: isReel ? "Instagram reel" : "Instagram post",
                creator: nil,
                tags: ["instagram"]
            )
        }

        if host.contains("youtube.com") || host.contains("youtu.be") {
            return LinkMetadata(
                source: .youtube,
                contentType: .youtubeVideo,
                title: displayTitle,
                description: "YouTube video",
                creator: nil,
                tags: ["youtube"]
            )
        }

        if host.contains("reddit.com") || host.contains("redd.it") {
            return LinkMetadata(
                source: .reddit,
                contentType: .redditPost,
                title: displayTitle,
                description: "Reddit link",
                creator: nil,
                tags: ["reddit"]
            )
        }

        return LinkMetadata(
            source: .website,
            contentType: .webpage,
            title: displayTitle,
            description: host.isEmpty ? nil : host,
            creator: nil,
            tags: host.isEmpty ? [] : [host.replacingOccurrences(of: "www.", with: "")]
        )
    }

    private static func title(for url: URL) -> String {
        if let host = url.host(percentEncoded: false), !host.isEmpty {
            return host.replacingOccurrences(of: "www.", with: "")
        }

        return url.absoluteString
    }
}
