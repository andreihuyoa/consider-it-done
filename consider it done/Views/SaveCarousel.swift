import SwiftUI

struct SaveCarousel: View {
    let saves: [SavedItem]
    let namespace: Namespace.ID
    let onSelect: (SavedItem) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var focusedID: UUID?
    @GestureState private var dragOffset: CGFloat = 0

    private var focusedIndex: Int {
        saves.firstIndex { $0.id == focusedID } ?? 0
    }

    var body: some View {
        if !saves.isEmpty {
            VStack(spacing: 16) {
                ZStack {
                    if focusedIndex + 2 < saves.count {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.figSurfaceMuted)
                            .padding(.horizontal, 20)
                            .offset(y: 16)
                            .accessibilityHidden(true)
                    }
                    if focusedIndex + 1 < saves.count {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.figSurfaceSoft)
                            .padding(.horizontal, 10)
                            .offset(y: 8)
                            .accessibilityHidden(true)
                    }

                    SaveCarouselCard(save: saves[focusedIndex], namespace: namespace) {
                        onSelect(saves[focusedIndex])
                    }
                    .id(saves[focusedIndex].id)
                    .offset(x: reduceMotion ? 0 : dragOffset * 0.35)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 24)
                            .updating($dragOffset) { value, offset, _ in
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    offset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                guard abs(value.translation.width) > 50,
                                      abs(value.translation.width) > abs(value.translation.height) else { return }
                                let direction = value.translation.width < 0 ? 1 : -1
                                let nextIndex = min(max(focusedIndex + direction, 0), saves.count - 1)
                                withAnimation(reduceMotion ? nil : .spring(response: 0.32, dampingFraction: 0.86)) {
                                    focusedID = saves[nextIndex].id
                                }
                            }
                    )
                }
                .frame(maxHeight: 640)
                .padding(.bottom, 16)

                // Swipe-only paging is explicitly accepted accessibility debt.
                // Keep this position label informational; no prev/next buttons.
                Text("\(focusedIndex + 1) of \(saves.count)")
                    .font(.text(.footnote))
                    .foregroundStyle(Color.figTextSoft)
            }
            .padding(.horizontal, 4)
            .onChange(of: saves.map(\.id)) { _, ids in
                if let focusedID, !ids.contains(focusedID) {
                    self.focusedID = ids.first
                }
            }
        }
    }
}
