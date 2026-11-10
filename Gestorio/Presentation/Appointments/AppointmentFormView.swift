import SwiftUI

struct AppointmentFormView: View {
    @State private var viewModel: AppointmentFormViewModel
    @Environment(\.dismiss) private var dismiss
    private let onSave: () -> Void

    init(appointment: Appointment? = nil, initialDate: Date = .now, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: AppointmentFormViewModel(appointment: appointment, initialDate: initialDate))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cliente") {
                    if viewModel.didLoadClients && viewModel.clients.isEmpty {
                        Text("Primero crea un cliente en la pestaña Clientes.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Cliente", selection: $viewModel.clientID) {
                            Text("Selecciona").tag(UUID?.none)
                            ForEach(viewModel.clients) { client in
                                Text(client.name).tag(UUID?.some(client.id))
                            }
                        }
                    }
                }

                Section("Cita") {
                    DatePicker("Fecha y hora", selection: $viewModel.date)
                    Stepper("Duración: \(viewModel.durationMinutes) min", value: $viewModel.durationMinutes, in: 15...480, step: 15)
                    TextField("Servicio", text: $viewModel.service)
                    HStack {
                        Text("Precio")
                        TextField("0,00", text: $viewModel.priceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: viewModel.priceText) {
                                viewModel.sanitizePriceText()
                            }
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Notas") {
                    TextField("Notas", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if viewModel.save() {
                            onSave()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .task {
            viewModel.loadClients()
        }
    }
}

#Preview {
    AppointmentFormView(onSave: {})
}
