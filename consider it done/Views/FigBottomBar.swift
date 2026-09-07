import SwiftUI

struct FigBottomBar: View {
    @Binding var selectedArea: FigArea

    let reduceMotion: Bool
    let onAdd: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .trailing, spacing: 8) {
                    VStack(spacing: 4) {
                        ForEach(FigArea.allCases) { area in
                            accessibilityTabButton(area)
                        }
                    }
                    .padding(4)
                    .background(Color.figSurfaceMuted, in: RoundedRectangle(cornerRadius: 24))
                    addButton
                }
            } else {
                HStack(alignment: .center, spacing: 16) {
                    tabButtons
                    addButton
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.figBackground)
    }

    private var tabButtons: some View {
        HStack(spacing: 4) {
            ForEach(FigArea.allCases) { area in
                Button {
                    select(area)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: area.symbol)
                            .font(.title3)
                        Text(area.title)
                            .font(.footnote)
                            .bold(selectedArea == area)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                    }
                    .foregroundStyle(selectedArea == area ? Color.figTextPrimary : Color.figTextSoft)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .padding(.vertical, 4)
                    .background(
                        selectedArea == area ? Color.figSurface : Color.clear,
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(area.title)
                .accessibilityAddTraits(selectedArea == area ? [.isSelected] : [])
                .accessibilityIdentifier("tab-\(area.id)")
            }
        }
        .padding(4)
        .background(Color.figSurfaceMuted, in: RoundedRectangle(cornerRadius: 24))
    }

    private func accessibilityTabButton(_ area: FigArea) -> some View {
        Button {
            select(area)
        } label: {
            Label(area.title, systemImage: area.symbol)
                .font(.footnote)
                .bold(selectedArea == area)
                .foregroundStyle(selectedArea == area ? Color.figTextPrimary : Color.figTextSoft)
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .padding(.horizontal, 16)
                .background(
                    selectedArea == area ? Color.figSurface : Color.clear,
                    in: RoundedRectangle(cornerRadius: 20)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(area.title)
        .accessibilityAddTraits(selectedArea == area ? [.isSelected] : [])
        .accessibilityIdentifier("tab-\(area.id)")
    }

    private var addButton: some View {
        Button("Add Link", systemImage: "plus", action: onAdd)
            .labelStyle(.iconOnly)
            .font(.title2.bold())
            .foregroundStyle(Color.figSurface)
            .frame(width: 56, height: 56)
            .background(Color.figAccent, in: Circle())
            .buttonStyle(.plain)
            .accessibilityIdentifier("add-link")
    }

    private func select(_ area: FigArea) {
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
            selectedArea = area
        }
    }
}
