//
//  VisualisortApp.swift
//  Visualisort
//
//  Created by chr1s on 2/11/25.
//

import SwiftUI

@main
struct VisualisortApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
