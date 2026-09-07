import SwiftUI

struct SearchSavesView: View {
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let isActive: Bool
    let onSelect: (SavedItem) -> Void

    @State private var query = ""
    @FocusState private var searchFocused: Bool

    private var searchText: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var results: [SavedItem] {
        guard !searchText.isEmpty else { return [] }
        return saves.filter { save in
            save.archivedAt == nil && (
                save.title.localizedStandardContains(searchText)
                    || save.sourceURL.absoluteString.localizedStandardContains(searchText)
                    || (save.itemDescription?.localizedStandardContains(searchText) ?? false)
                    || save.tags.contains { $0.name.localizedStandardContains(searchText) }
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Search")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .accessibilityHidden(true)
                TextField("Search saved links", text: $query)
                    .focused($searchFocused)
                    .submitLabel(.search)
                    .onSubmit { searchFocused = false }
#if os(iOS)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
#endif
                if !query.isEmpty {
                    Button("Clear search", systemImage: "xmark.circle.fill") {
                        query = ""
                    }
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
                }
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 52)
            .background(Color.figSurface, in: RoundedRectangle(cornerRadius: 12))

            if searchText.isEmpty {
                ContentUnavailableView("Find a saved link", systemImage: "magnifyingglass",
                    description: Text("Search titles, links, descriptions, and tags."))
            } else if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Inactive tabs must not register another source for a save
                        // already displayed by Saves in the shared namespace.
                        if isActive {
                            ForEach(results) { save in
                                Button {
                                    searchFocused = false
                                    onSelect(save)
                                } label: {
                                    SaveListCard(save: save, namespace: namespace)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(save.title)
                                .accessibilityHint("Opens saved link details")
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(Color.figTextPrimary)
        .background(Color.figBackground)
        .onChange(of: isActive) { _, active in
            if !active { searchFocused = false }
        }
    }
}
