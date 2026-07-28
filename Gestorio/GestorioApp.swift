//
//  GestorioApp.swift
//  Gestorio
//
//  Created by Álvaro Entrena Casas on 08/07/2026.
//

import SwiftUI
import SwiftData

@main
struct GestorioApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
