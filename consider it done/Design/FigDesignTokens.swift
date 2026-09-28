//
//  FigDesignTokens.swift
//  consider it done
//

import SwiftUI

// MARK: - Color
//
// Color tokens live in Assets.xcassets/Tokens as colorsets with a light and a
// dark appearance (values: design.md → "Color system"). Xcode generates the
// `Color.figBackground`, `Color.figSurface`, … symbols from those names, so
// views keep referencing tokens by name and never check `colorScheme`.

// MARK: - Typography
//
// Headings use Vollkorn Medium Italic; body text and controls use Figtree.
// Both scale with Dynamic Type through `relativeTo:`. Use them with the normal
// `.font(...)` modifier: `.font(.heading(.title2))`, `.font(.text(.callout))`.
// Letter spacing is tightened once at the app root with `.tracking(_:)`.

extension Font {
    /// Vollkorn Medium Italic, for screen, section, and save titles.
    static func heading(_ style: TextStyle) -> Font {
        .custom("VollkornItalic-Medium", size: baseSize(for: style), relativeTo: style)
    }

    /// Figtree, for body text, labels, and controls.
    static func text(_ style: TextStyle, weight: Weight = .regular) -> Font {
        .custom("Figtree-Regular", size: baseSize(for: style), relativeTo: style)
            .weight(weight)
    }

    /// iOS default (Large) point sizes for each text style.
    private static func baseSize(for style: TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }
}

extension CGFloat {
    /// App-wide letter spacing applied at the root view.
    static let textTracking: CGFloat = -0.2
}
