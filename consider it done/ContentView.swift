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
    case search = "Search"

    var id: String { rawValue }

    var title: String { self == .theFig ? "Saves" : rawValue }

    var symbol: String {
        switch self {
        case .theFig: "bookmark"
        case .collections: "square.stack"
        case .search: "magnifyingglass"
        }
    }
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

            tabContent
                .safeAreaInset(edge: .bottom, spacing: 0) {
#if os(iOS)
                    tabBar
#else
                    Button("Add Link", systemImage: "plus") { showAddLinkSheet = true }
                        .buttonStyle(.borderedProminent)
                        .tint(.figAccent)
                        .padding(16)
#endif
                }
                .disabled(selectedSave != nil)
                .allowsHitTesting(selectedSave == nil)
                .accessibilityHidden(selectedSave != nil)

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

    private var tabContent: some View {
        TabView(selection: $selectedArea) {
            Tab("Saves", systemImage: "bookmark", value: FigArea.theFig) {
                VStack(alignment: .leading, spacing: 16) {
                    header(title: "Saves", subtitle: showArchived
                        ? "\(theFigSaves.count) archived links."
                        : "\(theFigSaves.count) saved links.")
                    browsingSurface
                }
                .disabled(selectedArea != .theFig)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.figBackground)
            }
            Tab("Collections", systemImage: "square.stack", value: FigArea.collections) {
                VStack(alignment: .leading, spacing: 16) {
                    header(title: "Collections", subtitle: "Your saved links, collected.")
                    CollectionsOverview(saves: collectionsSaves)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.figBackground)
            }
            Tab("Search", systemImage: "magnifyingglass", value: FigArea.search) {
                SearchSavesView(
                    saves: collectionsSaves,
                    namespace: saveNamespace,
                    isActive: selectedArea == .search,
                    onSelect: openDetail
                )
                .disabled(selectedArea != .search)
            }
        }
#if os(iOS)
        .toolbarVisibility(.hidden, for: .tabBar)
#else
        .tabViewStyle(.automatic)
#endif
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: selectedArea)
    }

    private func header(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.figTextPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(Color.figTextSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // TabView owns destination identity; this strip reserves a separate add-action
    // slot, matching the reference without presenting Add Link as a fourth tab.
    private var tabBar: some View {
        HStack(alignment: .center, spacing: 16) {
            HStack(spacing: 4) {
                ForEach(FigArea.allCases) { area in
                    Button {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            selectedArea = area
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: area.symbol)
                                .font(.title3)
                            Text(area.title)
                                .font(.footnote)
                                .bold(selectedArea == area)
                        }
                        .foregroundStyle(selectedArea == area ? Color.figTextPrimary : Color.figTextSoft)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .padding(.vertical, 4)
                        .background(selectedArea == area ? Color.figSurface : Color.clear,
                                    in: RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(area.title)
                    .accessibilityAddTraits(selectedArea == area ? [.isSelected] : [])
                    .accessibilityIdentifier("tab-\(area.id)")
                }
            }
            .padding(4)
            .background(Color.figSurfaceMuted, in: RoundedRectangle(cornerRadius: 24))

            Button {
                showAddLinkSheet = true
            } label: {
                Label("Add Link", systemImage: "plus")
                    .labelStyle(.iconOnly)
                    .font(.title2.bold())
                    .foregroundStyle(Color.figSurface)
                    .frame(width: 56, height: 56)
                    .background(Color.figAccent, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("add-link")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.figBackground)
    }

    private var browsingSurface: some View {
        VStack(alignment: .leading, spacing: 16) {
            DensityControl(density: $density)

            archivedFilterChip

            if theFigSaves.isEmpty {
                EmptyFigState(selectedArea: .theFig)
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
                    .font(.title2.bold())
                    .foregroundStyle(Color.figTextPrimary)
                Spacer()
                Button {
                    showAddLinkSheet = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Color.figTextPrimary)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Close add link")
            }

            TextField("https://", text: $pendingURL)
                .textFieldStyle(.plain)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.figTextPrimary)
                .padding(16)
                .background(Color.figSurfaceMuted)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
