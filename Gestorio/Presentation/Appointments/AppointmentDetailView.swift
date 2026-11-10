import SwiftUI

struct AppointmentDetailView: View {
    let appointment: Appointment
    let clientName: String
    let onSaved: () -> Void
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss

    private var canEdit: Bool {
        appointment.invoiceID == nil && appointment.status != .invoiced
    }

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
                if appointment.status == .cancelled, let kind = appointment.cancellationKind {
                    LabeledContent(
                        "Cancelación",
                        value: kind == .justified ? "Justificada (no se cobra)" : "Sin justificar (se cobra)"
                    )
                }
            }

            if let notes = appointment.notes, !notes.isEmpty {
                Section("Notas") {
                    Text(notes)
                }
            }
        }
        .navigationTitle(appointment.service)
        .toolbar {
            if canEdit {
                ToolbarItem(placement: .primaryAction) {
                    Button("Editar") { isEditing = true }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AppointmentFormView(
                appointment: appointment,
                onSave: onSaved,
                onDelete: {
                    onSaved()
                    dismiss()
                }
            )
        }
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
            clientName: "Cliente de ejemplo",
            onSaved: {}
        )
    }
}
