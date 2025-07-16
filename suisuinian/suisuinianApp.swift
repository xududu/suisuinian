//
//  suisuinianApp.swift
//  suisuinian
//
//  Created by 徐文兴 on 2025/7/17.
//

import SwiftUI

@main
struct suisuinianApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
