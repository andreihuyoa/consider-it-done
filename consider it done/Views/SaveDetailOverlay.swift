//
//  SaveDetailOverlay.swift
//  consider it done
//
//  Created by Codex on 8/25/26.
//

import PhotosUI
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
    @State private var isEditing = false
    @State private var draftTitle = ""
    @State private var draftDescription = ""
    /// Custom image while editing; only written to the save on Save.
    @State private var draftCustomImage: Data?
    @State private var pickedImage: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.figShadow
                .ignoresSafeArea()
                .onTapGesture { if !isEditing { onClose() } }

            // Hug the content; scroll only when it is taller than the screen.
            ViewThatFits(in: .vertical) {
                card
                ScrollView { card }
                    .scrollBounceBehavior(.basedOnSize)
            }
            .frame(maxWidth: 560)
            .background(Color.figSurface)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .figShadow, radius: 24, x: 0, y: 12)
            .matchedGeometryEffect(id: save.id, in: namespace)
            .padding(16)
            .gesture(DragGesture(minimumDistance: 24).onEnded { value in
                if value.translation.height > 120, !isEditing { onClose() }
            })
            .onAppear {
                hasReminder = save.reminderDate != nil
                reminderDate = save.reminderDate ?? Date().addingTimeInterval(3600)
            }
            .onChange(of: pickedImage) { _, item in
                guard let item else { return }
                Task { await importImage(from: item) }
            }
        }
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            media

            VStack(alignment: .leading, spacing: 20) {
                if isEditing {
                    editFields
                    editActions
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Saved \(save.savedAt.formatted(.dateTime.month(.abbreviated).day().hour().minute()))")
                            .font(.text(.footnote, weight: .medium))
                            .foregroundStyle(Color.figTextMuted)

                        Text(save.title)
                            .font(.heading(.title))
                            .foregroundStyle(Color.figTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let description = save.itemDescription, !description.isEmpty {
                            Text(description)
                                .font(.text(.body))
                                .foregroundStyle(Color.figTextSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    SaveTagRow(tags: save.tags)

                    reminderRow

                    if confirmsDeletion {
                        deleteConfirmation
                    } else {
                        actionRow
                    }
                }
            }
            .padding(24)
        }
    }

    /// While editing, previews the draft image instead of the saved one.
    private var mediaImageData: Data? {
        isEditing ? (draftCustomImage ?? save.thumbnailData) : save.displayImageData
    }

    /// Full-bleed image with the source pill and a glass close button.
    private var media: some View {
        SaveThumbnail(data: mediaImageData, cornerRadius: 0, fixedHeight: mediaImageData == nil ? 96 : 240)
            .accessibilityHidden(true)
            .overlay(alignment: .bottomLeading) {
                SaveSourcePill(source: save.source)
                    .padding(16)
            }
            .overlay(alignment: .topTrailing) {
                if !isEditing {
                    closeButton
                }
            }
    }

    private var closeButton: some View {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.text(.callout, weight: .semibold))
                        .foregroundStyle(Color.figTextPrimary)
                        .frame(width: 44, height: 44)
                        .glassEffect(.regular.interactive(), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close details")
                .padding(12)
    }

    private var reminderRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $hasReminder) {
                Label("Remind me", systemImage: "bell")
                    .font(.text(.callout, weight: .medium))
                    .foregroundStyle(Color.figTextPrimary)
            }
            .tint(.figAccent)
            .onChange(of: hasReminder) { _, _ in scheduleReminder() }

            if hasReminder {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { reminderPickers }
                    VStack(alignment: .leading, spacing: 8) { reminderPickers }
                }
                .onChange(of: reminderDate) { _, _ in scheduleReminder() }
            }
        }
        .padding(16)
        .background(Color.figSurfaceMuted, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    @ViewBuilder
    private var reminderPickers: some View {
        DatePicker("Reminder date", selection: $reminderDate, in: Date()..., displayedComponents: .date)
            .labelsHidden()
            .fixedSize()
        DatePicker("Reminder time", selection: $reminderDate, displayedComponents: .hourAndMinute)
            .labelsHidden()
            .fixedSize()
    }

    /// Quiet circular actions on the left; Open Link is the one filled action, bottom right.
    private var actionRow: some View {
        HStack(spacing: 8) {
            Button(action: startEditing) {
                Image(systemName: "pencil")
            }
            .buttonStyle(CircleIconButtonStyle())
            .accessibilityLabel("Edit")

            Menu {
                ForEach(collections) { collection in
                    Button {
                        toggle(collection)
                    } label: {
                        Label(collection.name, systemImage: contains(collection) ? "checkmark" : "plus")
                    }
                }
            } label: {
                Image(systemName: "square.stack.3d.up")
                    .circleIcon()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add to Collection")

            Button(action: archive) {
                Image(systemName: save.archivedAt == nil ? "archivebox" : "arrow.uturn.backward")
            }
            .buttonStyle(CircleIconButtonStyle())
            .accessibilityLabel(save.archivedAt == nil ? "Archive" : "Restore")

            Button {
                confirmsDeletion = true
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(CircleIconButtonStyle(foreground: .red))
            .accessibilityLabel("Remove")

            Spacer(minLength: 8)

            Link(destination: save.sourceURL) {
                Image(systemName: "arrow.up.right")
                    .font(.text(.title3, weight: .semibold))
                    .foregroundStyle(Color.figSurface)
                    .frame(width: 56, height: 56)
                    .background(Color.figAccent, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open Link")
        }
    }

    /// Inline, in place of the action row, so the confirmation sits where the user tapped.
    private var deleteConfirmation: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) {
                deleteConfirmationTitle
                Spacer(minLength: 8)
                deleteConfirmationButtons
            }
            VStack(alignment: .leading, spacing: 12) {
                deleteConfirmationTitle
                HStack(spacing: 8) { deleteConfirmationButtons }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.figSurfaceMuted, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var deleteConfirmationTitle: some View {
        Text("Remove this save?")
            .font(.text(.callout, weight: .semibold))
            .foregroundStyle(Color.figTextPrimary)
    }

    @ViewBuilder
    private var deleteConfirmationButtons: some View {
        Button("Cancel") {
            confirmsDeletion = false
        }
        .font(.text(.callout, weight: .medium))
        .foregroundStyle(Color.figTextPrimary)
        .padding(.horizontal, 16)
        .frame(minHeight: 44)
        .background(Color.figSurface, in: Capsule())
        .buttonStyle(.plain)

        Button("Remove", role: .destructive) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [save.id.uuidString])
            onDelete()
        }
        .font(.text(.callout, weight: .semibold))
        .foregroundStyle(Color.figSurface)
        .padding(.horizontal, 16)
        .frame(minHeight: 44)
        .background(Color.red, in: Capsule())
        .buttonStyle(.plain)
    }

    private var editFields: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Title", text: $draftTitle, axis: .vertical)
                .font(.heading(.title3))
                .lineLimit(1...4)
                .editFieldStyle()

            TextField("Description", text: $draftDescription, axis: .vertical)
                .font(.text(.body))
                .lineLimit(2...8)
                .editFieldStyle()

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { imageActions }
                VStack(alignment: .leading, spacing: 8) { imageActions }
            }
        }
    }

    @ViewBuilder
    private var imageActions: some View {
        PhotosPicker(selection: $pickedImage, matching: .images) {
            Label(draftCustomImage == nil ? "Add Image" : "Replace Image", systemImage: "photo")
        }
        .buttonStyle(PillButtonStyle())

        if draftCustomImage != nil {
            Button {
                draftCustomImage = nil
            } label: {
                Label(save.thumbnailData == nil ? "Remove Image" : "Use Original Image", systemImage: "arrow.uturn.backward")
            }
            .buttonStyle(PillButtonStyle())
        }
    }

    /// Nothing is written to the save until Save is tapped.
    private var editActions: some View {
        HStack(spacing: 8) {
            Button("Cancel", action: cancelEditing)
                .buttonStyle(PillButtonStyle())

            Spacer(minLength: 8)

            Button("Save", action: finishEditing)
                .buttonStyle(PillButtonStyle(isProminent: true))
        }
    }

    private func startEditing() {
        draftTitle = save.title
        draftDescription = save.itemDescription ?? ""
        draftCustomImage = save.customImageData
        confirmsDeletion = false
        isEditing = true
    }

    private func cancelEditing() {
        pickedImage = nil
        isEditing = false
    }

    /// Saves the drafts. An empty title is not saved; the previous title stays.
    private func finishEditing() {
        let title = draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !title.isEmpty {
            save.title = title
        }
        let description = draftDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        save.itemDescription = description.isEmpty ? nil : description
        save.customImageData = draftCustomImage
        isEditing = false
    }

    private func importImage(from item: PhotosPickerItem) async {
        defer { pickedImage = nil }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        let prepared = await Task.detached { CustomImageProcessor.prepared(data) }.value
        if let prepared {
            draftCustomImage = prepared
        }
    }

    private func contains(_ collection: Collection) -> Bool {
        save.collections.contains(where: { $0.id == collection.id })
    }

    private func archive() {
        save.reminderDate = nil
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [save.id.uuidString])
        save.archivedAt = save.archivedAt == nil ? Date() : nil
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

private extension View {
    func editFieldStyle() -> some View {
        self
            .foregroundStyle(Color.figTextPrimary)
            .textFieldStyle(.plain)
            .fixedSize(horizontal: false, vertical: true)
            .padding(12)
            .background(Color.figSurfaceMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension View {
    func circleIcon(foreground: Color = .figTextPrimary) -> some View {
        self
            .font(.text(.callout, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: 44, height: 44)
            .background(Color.figSurfaceMuted, in: Circle())
            .contentShape(Circle())
    }
}

private struct CircleIconButtonStyle: ButtonStyle {
    var foreground: Color = .figTextPrimary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .circleIcon(foreground: foreground)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
    }
}

private struct PillButtonStyle: ButtonStyle {
    var isProminent = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.text(.callout, weight: .semibold))
            .foregroundStyle(isProminent ? Color.figSurface : Color.figTextPrimary)
            .padding(.horizontal, 18)
            .frame(minHeight: 44)
            .background(isProminent ? Color.figAccent : Color.figSurfaceMuted, in: Capsule())
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
