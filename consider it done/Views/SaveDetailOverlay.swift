//
//  SaveDetailOverlay.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import SwiftUI
import SwiftData
import UserNotifications

struct SaveDetailOverlay: View {
    let save: SavedItem
    let namespace: Namespace.ID
    let onClose: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void
    @Query private var collections: [Collection]
    @State private var hasReminder = false
    @State private var reminderDate = Date().addingTimeInterval(3600)
    @State private var confirmsDeletion = false

    var body: some View {
        ZStack {
            Color.figTextPrimary.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture(perform: onClose)

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    SaveThumbnail(data: save.thumbnailData)
                        .frame(maxWidth: 180)

                    SaveSourceMark(source: save.source)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderless)
                    .foregroundStyle(Color.figTextPrimary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(save.title)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.figTextPrimary)

                    Text(save.sourceURL.absoluteString)
                        .font(.callout)
                        .foregroundStyle(Color.figTextSoft)
                        .textSelection(.enabled)
                }

                if let description = save.itemDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(Color.figTextSoft)
                }

                SaveTagRow(tags: save.tags)

                Toggle("Remind me", isOn: $hasReminder)
                    .tint(.figAccent)
                    .onChange(of: hasReminder) { _, _ in scheduleReminder() }

                if hasReminder {
                    DatePicker("Reminder date", selection: $reminderDate, in: Date()...)
                        .onChange(of: reminderDate) { _, _ in scheduleReminder() }
                }

                Menu {
                    ForEach(collections) { collection in
                        Button {
                            toggle(collection)
                        } label: {
                            Label(collection.name, systemImage: contains(collection) ? "checkmark" : "plus")
                        }
                    }
                } label: {
                    Label("Add to Collection", systemImage: "square.stack.3d.up")
                }
                .buttonStyle(.bordered)

                HStack(spacing: 8) {
                    Link(destination: save.sourceURL) {
                        Label("Open Link", systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.figAccent)

                    Button(action: archive) {
                        Label("Archive", systemImage: "archivebox")
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        confirmsDeletion = true
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
            .frame(maxWidth: 560, alignment: .leading)
            .background(Color.figSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: .figShadow, radius: 24, x: 0, y: 12)
            .matchedGeometryEffect(id: save.id, in: namespace)
            .padding(24)
            .gesture(DragGesture(minimumDistance: 24).onEnded { value in
                if value.translation.height > 120 { onClose() }
            })
            .onAppear {
                hasReminder = save.reminderDate != nil
                reminderDate = save.reminderDate ?? Date().addingTimeInterval(3600)
            }
            .confirmationDialog("Remove this saved link?", isPresented: $confirmsDeletion, titleVisibility: .visible) {
                Button("Remove", role: .destructive) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [save.id.uuidString])
                    onDelete()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private func contains(_ collection: Collection) -> Bool {
        save.collections.contains(where: { $0.id == collection.id })
    }

    private func archive() {
        save.reminderDate = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [save.id.uuidString])
        onArchive()
    }

    private func toggle(_ collection: Collection) {
        if contains(collection) {
            save.collections.removeAll(where: { $0.id == collection.id })
        } else {
            save.collections.append(collection)
        }
    }

    private func scheduleReminder() {
        guard hasReminder else {
            save.reminderDate = nil
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [save.id.uuidString])
            return
        }

        save.reminderDate = reminderDate
        let content = UNMutableNotificationContent()
        content.title = "The Fig"
        content.body = save.title
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let request = UNNotificationRequest(identifier: save.id.uuidString, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }
            UNUserNotificationCenter.current().add(request)
        }
    }
}
