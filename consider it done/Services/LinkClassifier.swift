//
//  LinkClassifier.swift
//  consider it done
//

import Foundation

#if os(iOS)
import UIKit // NSAttributedString HTML decoding options are defined by UIKit.
#elseif os(macOS)
import AppKit // NSAttributedString HTML decoding options are defined by AppKit.
#endif

struct LinkMetadata {
    let source: SaveSource
    let title: String
    let description: String?
    let thumbnailURL: URL?
    let thumbnailData: Data?
    let tags: [String]
}

enum LinkClassifier {
    static func classifySource(_ url: URL) -> SaveSource {
        let host = (url.host(percentEncoded: false) ?? "").lowercased()
        if host.contains("instagram.com") { return .instagram }
        if host.contains("youtube.com") || host.contains("youtu.be") { return .youtube }
        if host.contains("reddit.com") || host.contains("redd.it") { return .reddit }
        if host.contains("facebook.com") || host.contains("fb.watch") { return .facebook }
        return .other
    }

    static func metadata(for url: URL) async -> LinkMetadata {
        let source = classifySource(url)

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let html = String(decoding: data, as: UTF8.self)
            let openGraph = OpenGraphParser.parse(html, baseURL: url)
            let thumbnailData = await downloadImage(from: openGraph.imageURL)

            return LinkMetadata(
                source: source,
                title: openGraph.title ?? url.absoluteString,
                description: openGraph.description,
                thumbnailURL: openGraph.imageURL,
                thumbnailData: thumbnailData,
                tags: []
            )
        } catch {
            return LinkMetadata(source: source, title: url.absoluteString, description: nil, thumbnailURL: nil, thumbnailData: nil, tags: [])
        }
    }

    private static func downloadImage(from url: URL?) async -> Data? {
        guard let url else { return nil }
        return try? await URLSession.shared.data(from: url).0
    }
}

private struct OpenGraphMetadata {
    let title: String?
    let description: String?
    let imageURL: URL?
}

private enum OpenGraphParser {
    static func parse(_ html: String, baseURL: URL) -> OpenGraphMetadata {
        let metaRegex = try? NSRegularExpression(pattern: #"<meta\b[^>]*>"#, options: [.caseInsensitive])
        let attributeRegex = try? NSRegularExpression(pattern: #"([\w:-]+)\s*=\s*([\"'])(.*?)\2"#, options: [.caseInsensitive])
        var values: [String: String] = [:]
        let fullRange = NSRange(html.startIndex..<html.endIndex, in: html)

        metaRegex?.enumerateMatches(in: html, range: fullRange) { match, _, _ in
            guard let match, let tagRange = Range(match.range, in: html), let attributeRegex else { return }
            let tag = String(html[tagRange])
            let attributeRange = NSRange(tag.startIndex..<tag.endIndex, in: tag)
            var property: String?
            var content: String?

            attributeRegex.enumerateMatches(in: tag, range: attributeRange) { attributeMatch, _, _ in
                guard let attributeMatch,
                      let nameRange = Range(attributeMatch.range(at: 1), in: tag),
                      let valueRange = Range(attributeMatch.range(at: 3), in: tag) else { return }
                let name = tag[nameRange].lowercased()
                let value = decodeEntities(String(tag[valueRange])).trimmingCharacters(in: .whitespacesAndNewlines)
                if name == "property" || name == "name" { property = value.lowercased() }
                if name == "content" { content = value }
            }

            if let property, let content, !content.isEmpty { values[property] = content }
        }

        let imageURL = values["og:image"].flatMap { URL(string: $0, relativeTo: baseURL)?.absoluteURL }
        return OpenGraphMetadata(title: values["og:title"], description: values["og:description"], imageURL: imageURL)
    }

    private static func decodeEntities(_ value: String) -> String {
        guard let data = value.data(using: .utf8) else { return value }
        return (try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil).string) ?? value
    }
}
