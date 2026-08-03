import SwiftUI

struct AppointmentDetailView: View {
    let appointment: Appointment
    let clientName: String

    var body: some View {
        Form {
            Section("Cliente") {
                Text(clientName)
            }

            Section("Cita") {
                LabeledContent("Fecha", value: appointment.date.formatted(.dateTime.day().month(.wide).year()))
                LabeledContent("Hora", value: appointment.date.formatted(.dateTime.hour().minute()))
                LabeledContent("Duración", value: "\(appointment.durationMinutes) min")
                LabeledContent("Servicio", value: appointment.service)
                LabeledContent("Precio", value: appointment.price.formatted(.currency(code: "EUR")))
                LabeledContent("Estado", value: appointment.status.rawValue)
            }

            if let notes = appointment.notes, !notes.isEmpty {
                Section("Notas") {
                    Text(notes)
                }
            }
        }
        .navigationTitle(appointment.service)
    }
}

#Preview {
    NavigationStack {
        AppointmentDetailView(
            appointment: Appointment(
                clientID: UUID(),
                date: .now,
                durationMinutes: 60,
                service: "Consulta",
                price: 50
            ),
            clientName: "Cliente de ejemplo"
        )
    }
}
