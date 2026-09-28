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
    @State private var showNotifications = false
    @State private var showArchived = false
    @State private var isRecoveringFromDensityGesture = false
    /// Measured height of the bottom bar; tab content doesn't inherit its inset.
    @State private var bottomBarHeight: CGFloat = 0
    @State private var interactionResetTask: Task<Void, Never>?
    @GestureState private var isChangingDensity = false

    private var blocksSaveInteractions: Bool {
        isChangingDensity || isRecoveringFromDensityGesture
    }

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
                .overlay(alignment: .topTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        Label("Notifications", systemImage: "bell")
                            .labelStyle(.iconOnly)
                            .font(.text(.title3))
                            .foregroundStyle(Color.figTextPrimary)
                            .frame(width: 44, height: 44)
                            .background(Color.figSurface, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("notifications")
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    Group {
#if os(iOS)
                        BottomBar(
                            selectedArea: $selectedArea,
                            reduceMotion: reduceMotion,
                            onAdd: { showAddLinkSheet = true }
                        )
#else
                        Button("Add Link", systemImage: "plus") { showAddLinkSheet = true }
                            .buttonStyle(.borderedProminent)
                            .tint(.figAccent)
                            .padding(16)
#endif
                    }
                    .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { bottomBarHeight = $0 }
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
        .font(.text(.body))
        .tracking(.textTracking)
        .sheet(isPresented: $showAddLinkSheet) {
            addLinkSheet
                .font(.text(.body))
                .tracking(.textTracking)
        }
        .sheet(isPresented: $showNotifications) {
            NotificationsView(saves: saves)
                .font(.text(.body))
                .tracking(.textTracking)
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
                .hidesSystemTabBar()
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
                .hidesSystemTabBar()
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
                .hidesSystemTabBar()
            }
        }
#if os(macOS)
        .tabViewStyle(.automatic)
#endif
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: selectedArea)
    }

    private func header(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.heading(.largeTitle))
                .padding(.trailing, 56)
                .foregroundStyle(Color.figTextPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(subtitle)
                .font(.text(.callout))
                .foregroundStyle(Color.figTextSoft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var browsingSurface: some View {
        VStack(alignment: .leading, spacing: 16) {
            archivedFilterChip

            if theFigSaves.isEmpty {
                EmptyFigState(selectedArea: .theFig)
            } else if density == .list {
                // The carousel fits the space between header and bottom bar; no scrolling.
                DensityContainer(
                    density: density,
                    saves: theFigSaves,
                    namespace: saveNamespace,
                    onSelect: { save in
                        guard !blocksSaveInteractions else { return }
                        openDetail(save)
                    }
                )
                .padding(.bottom, bottomBarHeight + 8)
                .frame(maxHeight: .infinity)
                .allowsHitTesting(!blocksSaveInteractions)
            } else {
                ScrollView {
                    DensityContainer(
                        density: density,
                        saves: theFigSaves,
                        namespace: saveNamespace,
                        onSelect: { save in
                            guard !blocksSaveInteractions else { return }
                            openDetail(save)
                        }
                    )
                    .padding(.vertical, 8)
                    .allowsHitTesting(!blocksSaveInteractions)
                }
                .scrollDisabled(blocksSaveInteractions)
                .contentMargins(.bottom, bottomBarHeight, for: .scrollContent)
            }
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            MagnifyGesture()
                .updating($isChangingDensity) { _, isChangingDensity, _ in
                    isChangingDensity = true
                }
                .onEnded { value in
                    endDensityGesture(with: value.magnification)
                }
        )
        // The visible density picker was removed; pinch is the on-screen control.
        // These keep density reachable without a pinch (design.md → "Density levels").
        .accessibilityAction(named: "Closer layout") { stepDensity(to: density.nextCloser) }
        .accessibilityAction(named: "Wider layout") { stepDensity(to: density.nextFarther) }
        .background {
            Group {
                Button("Closer layout") { stepDensity(to: density.nextCloser) }
                    .keyboardShortcut("=", modifiers: .command)
                Button("Wider layout") { stepDensity(to: density.nextFarther) }
                    .keyboardShortcut("-", modifiers: .command)
            }
            .opacity(0)
            .accessibilityHidden(true)
        }
    }

    private var archivedFilterChip: some View {
        Button {
            showArchived.toggle()
        } label: {
            Label("Archived", systemImage: showArchived ? "archivebox.fill" : "archivebox")
                .font(.text(.caption, weight: .semibold))
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
                    .font(.heading(.title2))
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
                .font(.text(.title3, weight: .medium))
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
                    .font(.text(.callout))
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
        stepDensity(to: nextDensity)
    }

    private func stepDensity(to nextDensity: BrowseDensity) {
        guard nextDensity != density else { return }

        withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86)) {
            density = nextDensity
        }
    }

    private func endDensityGesture(with magnification: CGFloat) {
        interactionResetTask?.cancel()
        isRecoveringFromDensityGesture = true
        changeDensity(with: magnification)

        interactionResetTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(200))
            guard !Task.isCancelled else { return }
            isRecoveringFromDensityGesture = false
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

private extension View {
    /// The custom BottomBar replaces the system tab bar on iOS.
    @ViewBuilder
    func hidesSystemTabBar() -> some View {
#if os(iOS)
        toolbarVisibility(.hidden, for: .tabBar)
#else
        self
#endif
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
