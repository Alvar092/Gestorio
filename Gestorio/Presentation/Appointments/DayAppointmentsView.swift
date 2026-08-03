import SwiftUI

struct DayAppointmentsView: View {
    let date: Date
    let appointments: [Appointment]
    let clientName: (Appointment) -> String

    var body: some View {
        Group {
            if appointments.isEmpty {
                ContentUnavailableView("Sin citas", systemImage: "calendar.badge.exclamationmark", description: Text("No hay citas para este día."))
            } else {
                List(appointments) { appointment in
                    NavigationLink(value: appointment) {
                        row(for: appointment)
                    }
                }
            }
        }
        .navigationTitle(date.formatted(.dateTime.day().month(.wide).year()))
    }

    private func row(for appointment: Appointment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(clientName(appointment))
                .font(.headline)
            Text(appointment.service)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(appointment.date, format: .dateTime.hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        DayAppointmentsView(date: .now, appointments: [], clientName: { _ in "" })
    }
}
