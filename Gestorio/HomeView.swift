//
//  HomeView.swift
//  Gestorio
//
//  Created by Álvaro Entrena Casas on 08/07/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }

            AppointmentsCalendarView()
                .tabItem {
                    Label("Calendario", systemImage: "calendar")
                }

            ClientsView()
                .tabItem {
                    Label("Clientes", systemImage: "person.2")
                }

            ActivityView()
                .tabItem {
                    Label("Actividad", systemImage: "list.bullet.rectangle")
                }
        }
    }
}

#Preview {
    HomeView()
}
