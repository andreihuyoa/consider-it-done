//
//  ContentView.swift
//  consider it done
//
//  Created by Andrei Huyo-a on 8/18/26.
//

import SwiftData
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum FigArea: String, CaseIterable, Identifiable {
    case theFig = "The Fig"
    case collections = "Collections"
    case save = "Save"
    case archive = "Archive"

    var id: String { rawValue }
}

enum BrowseDensity: Int, CaseIterable {
    case organization
    case grid
    case list

    var nextCloser: BrowseDensity {
        BrowseDensity(rawValue: min(rawValue + 1, BrowseDensity.list.rawValue)) ?? .list
    }

    var nextFarther: BrowseDensity {
        BrowseDensity(rawValue: max(rawValue - 1, BrowseDensity.organization.rawValue)) ?? .organization
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var saveNamespace
    @Query(sort: \SavedItem.savedAt, order: .reverse) private var saves: [SavedItem]

    @State private var selectedArea: FigArea = .theFig
    @State private var density: BrowseDensity = .grid
    @State private var selectedSave: SavedItem?
    @State private var pendingURL = ""
    @State private var saveError: String?

    private var visibleSaves: [SavedItem] {
        switch selectedArea {
        case .theFig:
            saves.filter { $0.status == .inbox }
        case .archive:
            saves.filter { $0.status == .archived }
        case .collections, .save:
            saves.filter { $0.status != .archived }
        }
    }

    var body: some View {
        ZStack {
            Color.figBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                header
                areaPicker

                Group {
                    switch selectedArea {
                    case .save:
                        saveComposer
                    case .collections:
                        CollectionsOverview(saves: visibleSaves)
                    case .theFig, .archive:
                        browsingSurface
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(24)

            if let selectedSave {
                SaveDetailOverlay(
                    save: selectedSave,
                    namespace: saveNamespace,
                    onClose: { closeDetail() },
                    onArchive: { archive(selectedSave) }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
#if os(macOS)
        .frame(minWidth: 760, minHeight: 620)
#endif
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The Fig")
                .font(.largeTitle.weight(.semibold))
                .foregroundStyle(Color.figTextPrimary)

            Text(headerSubtitle)
                .font(.callout)
                .foregroundStyle(Color.figTextSoft)
        }
    }

    private var headerSubtitle: String {
        switch selectedArea {
        case .theFig:
            "\(visibleSaves.count) links waiting to become useful."
        case .collections:
            "Collections are stacks of saved links, not folders."
        case .save:
            "Paste a URL to add it to The Fig."
        case .archive:
            "\(visibleSaves.count) links moved out of the inbox."
        }
    }

    private var areaPicker: some View {
        Picker("Area", selection: $selectedArea) {
            ForEach(FigArea.allCases) { area in
                Text(area.rawValue).tag(area)
            }
        }
        .pickerStyle(.segmented)
        .tint(.figAccent)
    }

    private var browsingSurface: some View {
        VStack(alignment: .leading, spacing: 16) {
            DensityControl(density: $density)

            if visibleSaves.isEmpty {
                EmptyFigState(selectedArea: selectedArea)
            } else {
                ScrollView {
                    DensityContainer(
                        density: density,
                        saves: visibleSaves,
                        namespace: saveNamespace,
                        onSelect: { save in
                            openDetail(save)
                        }
                    )
                    .padding(.vertical, 8)
                }
                .gesture(
                    MagnifyGesture()
                        .onEnded { value in
                            changeDensity(with: value.magnification)
                        }
                )
            }
        }
    }

    private var saveComposer: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("https://", text: $pendingURL)
                .textFieldStyle(.plain)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.figTextPrimary)
                .padding(16)
                .background(Color.figSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
#if os(iOS)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
#endif

            HStack(spacing: 8) {
                Button(action: savePendingURL) {
                    Label("Save Link", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(.figAccent)

                Button(action: pasteFromClipboard) {
                    Label("Paste", systemImage: "doc.on.clipboard")
                }
                .buttonStyle(.bordered)
            }

            if let saveError {
                Text(saveError)
                    .font(.callout)
                    .foregroundStyle(Color.figTextSoft)
            }

            Text("Share Extension and macOS menu-bar capture will write into this same Save model.")
                .font(.footnote)
                .foregroundStyle(Color.figTextMuted)
        }
        .frame(maxWidth: 620, alignment: .leading)
    }

    private func changeDensity(with magnification: CGFloat) {
        let nextDensity = magnification > 1 ? density.nextCloser : density.nextFarther
        guard nextDensity != density else { return }

        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86)) {
            density = nextDensity
        }
    }

    private func openDetail(_ save: SavedItem) {
        withAnimation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.88)) {
            selectedSave = save
        }
    }

    private func closeDetail() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.9)) {
            selectedSave = nil
        }
    }

    private func archive(_ save: SavedItem) {
        save.status = .archived
        closeDetail()
    }

    private func savePendingURL() {
        let trimmedURL = pendingURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmedURL), url.scheme != nil, url.host(percentEncoded: false) != nil else {
            saveError = "Enter a full URL, including https://."
            return
        }

        modelContext.insert(SavedItem.make(from: url))
        pendingURL = ""
        saveError = nil
        selectedArea = .theFig
    }

    private func pasteFromClipboard() {
#if os(iOS)
        if let value = UIPasteboard.general.string {
            pendingURL = value
        }
#elseif os(macOS)
        if let value = NSPasteboard.general.string(forType: .string) {
            pendingURL = value
        }
#endif
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
