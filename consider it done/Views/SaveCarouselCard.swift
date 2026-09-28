import SwiftUI

struct SaveCarouselCard: View {
    @Environment(\.isEnabled) private var isEnabled
    let save: SavedItem
    let namespace: Namespace.ID
    let onSelect: () -> Void

    var body: some View {
        SaveCard(save: save, style: .hero, onSelect: onSelect)
            .matchedGeometryEffect(id: save.id, in: namespace, isSource: isEnabled)
    }
}
