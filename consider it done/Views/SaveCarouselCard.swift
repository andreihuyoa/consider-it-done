import SwiftUI

struct SaveCarouselCard: View {
    @Environment(\.isEnabled) private var isEnabled
    let save: SavedItem
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SaveThumbnail(data: save.thumbnailData)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 12) {
                SaveSourceMark(source: save.source)
                Text(save.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.figTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                if let description = save.itemDescription, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Color.figTextSoft)
                        .lineLimit(3)
                }
                SaveTagRow(tags: save.tags)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.figSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .figShadow, radius: 12, x: 0, y: 4)
        .matchedGeometryEffect(id: save.id, in: namespace, isSource: isEnabled)
    }
}
