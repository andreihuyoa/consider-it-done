//
//  MenuBarSaveView.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftData
import SwiftUI

#if os(macOS)
import AppKit

struct MenuBarSaveView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var pendingURL = ""
    @State private var message = "Paste a URL to save it."

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Fig")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.figTextPrimary)

            TextField("https://", text: $pendingURL)
                .textFieldStyle(.roundedBorder)

            HStack(spacing: 8) {
                Button("Paste") {
                    pendingURL = NSPasteboard.general.string(forType: .string) ?? ""
                }

                Button("Save") {
                    savePendingURL()
                }
                .buttonStyle(.borderedProminent)
                .tint(.figAccent)
            }

            Text(message)
                .font(.footnote)
                .foregroundStyle(Color.figTextSoft)
        }
        .padding(16)
        .frame(width: 320)
        .background(Color.figBackground)
    }

    private func savePendingURL() {
        let trimmedURL = pendingURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmedURL), url.scheme != nil, url.host(percentEncoded: false) != nil else {
            message = "Use a full URL, including https://."
            return
        }

        modelContext.insert(SavedItem.make(from: url))
        pendingURL = ""
        message = "Saved to The Fig."
    }
}
#endif
