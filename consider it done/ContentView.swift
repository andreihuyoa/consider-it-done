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
    @State private var showAddLinkSheet = false
    @State private var showArchived = false

    private var theFigSaves: [SavedItem] {
        saves.filter { showArchived ? $0.archivedAt != nil : $0.archivedAt == nil }
    }

    private var collectionsSaves: [SavedItem] {
        saves.filter { $0.archivedAt == nil }
    }

    var body: some View {
        ZStack {
            Color.figBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    header

                    Group {
                        switch selectedArea {
                        case .collections:
                            CollectionsOverview(saves: collectionsSaves)
                        case .theFig:
                            browsingSurface
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                tabBar
            }

            fab

            if let selectedSave {
                SaveDetailOverlay(
                    save: selectedSave,
                    namespace: saveNamespace,
                    onClose: { closeDetail() },
                    onArchive: { closeDetail() },
                    onDelete: { remove(selectedSave) }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
#if os(macOS)
        .frame(minWidth: 760, minHeight: 620)
#endif
        .sheet(isPresented: $showAddLinkSheet) {
            addLinkSheet
        }
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
            showArchived ? "\(theFigSaves.count) archived links." : "\(theFigSaves.count) saved links."
        case .collections:
            "Collections are stacks of saved links, not folders."
        }
    }

    private var tabBar: some View {
        HStack(spacing: 8) {
            ForEach(FigArea.allCases) { area in
                Button {
                    selectedArea = area
                } label: {
                    Text(area.rawValue)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(selectedArea == area ? Color.figTextPrimary : Color.figTextMuted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedArea == area ? Color.figSurface : Color.clear,
                            in: RoundedRectangle(cornerRadius: 23, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.figSurfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private var fab: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showAddLinkSheet = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.figSurface)
                        .frame(width: 56, height: 56)
                        .background(Color.figAccent, in: Circle())
                        .shadow(color: .figShadow, radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 24)
                .padding(.bottom, 84)
            }
        }
    }

    private var browsingSurface: some View {
        VStack(alignment: .leading, spacing: 16) {
            DensityControl(density: $density)

            archivedFilterChip

            if theFigSaves.isEmpty {
                EmptyFigState(selectedArea: selectedArea)
            } else {
                ScrollView {
                    DensityContainer(
                        density: density,
                        saves: theFigSaves,
                        namespace: saveNamespace,
                        onSelect: { save in
                            openDetail(save)
                        }
                    )
                    .padding(.vertical, 8)
                }
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            MagnifyGesture()
                .onEnded { value in
                    changeDensity(with: value.magnification)
                }
        )
    }

    private var archivedFilterChip: some View {
        Button {
            showArchived.toggle()
        } label: {
            Label("Archived", systemImage: showArchived ? "archivebox.fill" : "archivebox")
                .font(.caption.weight(.semibold))
                .foregroundStyle(showArchived ? Color.figSurface : Color.figTextMuted)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    showArchived ? Color.figAccent : Color.figSurfaceMuted,
                    in: Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    private var addLinkSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Add a link")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.figTextPrimary)
                Spacer()
                Button {
                    showAddLinkSheet = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Color.figTextPrimary)
            }

            TextField("https://", text: $pendingURL)
                .textFieldStyle(.plain)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.figTextPrimary)
                .padding(16)
                .background(Color.figSurfaceMuted)
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

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.figBackground)
        .presentationDetents([.medium])
    }

    private func changeDensity(with magnification: CGFloat) {
        let nextDensity: BrowseDensity
        if magnification > 1.05 {
            nextDensity = density.nextCloser
        } else if magnification < 0.95 {
            nextDensity = density.nextFarther
        } else {
            return
        }
        guard nextDensity != density else { return }

        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86)) {
            density = nextDensity
        }
    }

    private func openDetail(_ save: SavedItem) {
        save.viewedAt = Date()
        withAnimation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.88)) {
            selectedSave = save
        }
    }

    private func closeDetail() {
        withAnimation(reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.9)) {
            selectedSave = nil
        }
    }

    private func remove(_ save: SavedItem) {
        closeDetail()
        modelContext.delete(save)
    }

    private func savePendingURL() {
        let trimmedURL = pendingURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmedURL), url.scheme != nil, url.host(percentEncoded: false) != nil else {
            saveError = "Enter a full URL, including https://."
            return
        }

        Task {
            let metadata = await LinkClassifier.metadata(for: url)
            await MainActor.run {
                modelContext.insert(SavedItem.make(from: url, metadata: metadata))
                pendingURL = ""
                saveError = nil
                showAddLinkSheet = false
            }
        }
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
