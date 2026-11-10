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
            HomeView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
