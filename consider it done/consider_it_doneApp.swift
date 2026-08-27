//
//  consider_it_doneApp.swift
//  consider it done
//
//  Created by Andrei Huyo-a on 8/18/26.
//

import SwiftData
import SwiftUI

@main
struct consider_it_doneApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedItem.self,
            Collection.self,
            Tag.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)

#if os(macOS)
        MenuBarExtra("The Fig", systemImage: "tray.full") {
            MenuBarSaveView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
#endif
    }
}
