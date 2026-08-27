//
//  EmptyFigState.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct EmptyFigState: View {
    let selectedArea: FigArea

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.figTextPrimary)

            Text(message)
                .font(.body)
                .foregroundStyle(Color.figTextSoft)
                .frame(maxWidth: 420, alignment: .leading)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
        .background(Color.figSurfaceSoft)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var title: String {
        switch selectedArea {
        case .theFig:
            "No links in The Fig yet."
        case .collections:
            "No collection stacks yet."
        case .save:
            "Save a link."
        }
    }

    private var message: String {
        switch selectedArea {
        case .theFig:
            "Use Save to add Instagram, YouTube, Reddit, or website URLs."
        case .collections:
            "As links build up, this area will make groups feel like physical stacks."
        case .save:
            "Paste a full URL to classify and store it."
        }
    }
}
