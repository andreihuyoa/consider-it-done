import SwiftUI

struct NotificationsView: View {
    let saves: [SavedItem]

    @Environment(\.dismiss) private var dismiss

    private var recentSaves: [SavedItem] {
        saves.filter { $0.archivedAt == nil }
            .sorted { $0.savedAt > $1.savedAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Notifications")
                .font(.heading(.title2))
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 8)
                .accessibilityAddTraits(.isHeader)

            TimelineView(.periodic(from: .now, by: 60)) { timeline in
                List {
                    Section("Recently saved") {
                        if recentSaves.isEmpty {
                            Text("No saved links yet.")
                                .foregroundStyle(Color.figTextSoft)
                        } else {
                            ForEach(recentSaves) { save in
                                notificationRow(save, date: save.savedAt)
                            }
                        }
                    }
                    .listRowBackground(Color.figSurface)

                    Section("Upcoming reminders") {
                        let upcoming = upcomingSaves(after: timeline.date)
                        if upcoming.isEmpty {
                            Text("No upcoming reminders.")
                                .foregroundStyle(Color.figTextSoft)
                        } else {
                            ForEach(upcoming) { save in
                                if let date = save.reminderDate {
                                    notificationRow(save, date: date)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.figSurface)
                }
#if os(macOS)
                .listStyle(.inset)
#else
                .listStyle(.insetGrouped)
#endif
                .scrollContentBackground(.hidden)
            }
        }
        .foregroundStyle(Color.figTextPrimary)
        .background(Color.figBackground)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .accessibilityAction(.escape) { dismiss() }
    }

    private func upcomingSaves(after date: Date) -> [SavedItem] {
        recentSaves.filter { ($0.reminderDate ?? .distantPast) > date }
            .sorted { ($0.reminderDate ?? .distantFuture) < ($1.reminderDate ?? .distantFuture) }
    }

    private func notificationRow(_ save: SavedItem, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(save.title)
                .font(.heading(.headline))
                .fixedSize(horizontal: false, vertical: true)
            Text(date, format: .dateTime.month(.abbreviated).day().hour().minute())
                .font(.text(.footnote))
                .foregroundStyle(Color.figTextSoft)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
