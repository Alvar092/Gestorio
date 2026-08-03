//
//  ContentView.swift
//  Gestorio
//
//  Created by Álvaro Entrena Casas on 08/07/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            AppointmentsCalendarView()
                .tabItem {
                    Label("Calendario", systemImage: "calendar")
                }

            ClientsView()
                .tabItem {
                    Label("Clientes", systemImage: "person.2")
                }

            InvoicesView()
                .tabItem {
                    Label("Facturas", systemImage: "doc.text")
                }
        }
    }
}

#Preview {
    ContentView()
}
