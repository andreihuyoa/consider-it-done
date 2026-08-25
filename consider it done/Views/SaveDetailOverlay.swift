//
//  SaveDetailOverlay.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI

struct SaveDetailOverlay: View {
    let save: SavedItem
    let namespace: Namespace.ID
    let onClose: () -> Void
    let onArchive: () -> Void

    var body: some View {
        ZStack {
            Color.figTextPrimary.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    SaveSourceMark(source: save.source)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(Color.figTextPrimary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(save.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.figTextPrimary)

                    Text(save.sourceURL.absoluteString)
                        .font(.callout)
                        .foregroundStyle(Color.figTextSoft)
                        .textSelection(.enabled)
                }

                if let description = save.itemDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Color.figTextSoft)
                }

                SaveTagRow(tags: save.tags)

                HStack(spacing: 8) {
                    Link(destination: save.sourceURL) {
                        Label("Open Link", systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.figAccent)

                    Button(action: onArchive) {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
            .background(Color.figSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .figShadow, radius: 24, x: 0, y: 12)
            .matchedGeometryEffect(id: save.id, in: namespace)
            .padding(24)
        }
    }
}
