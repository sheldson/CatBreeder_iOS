//
//  CatBreederApp.swift
//  CatBreeder
//
//  Created by Sheldon027 on 2025/8/23.
//

import SwiftUI

@main
struct CatBreederApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
