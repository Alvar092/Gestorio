import SwiftUI

struct AppointmentFormView: View {
    @State private var viewModel: AppointmentFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingDelete = false
    @State private var isChoosingCancellation = false
    private let onSave: () -> Void
    private let onDelete: () -> Void

    init(appointment: Appointment? = nil, initialDate: Date = .now, onSave: @escaping () -> Void, onDelete: @escaping () -> Void = {}) {
        _viewModel = State(initialValue: AppointmentFormViewModel(appointment: appointment, initialDate: initialDate))
        self.onSave = onSave
        self.onDelete = onDelete
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

                if viewModel.canDelete || viewModel.canCancel {
                    Section {
                        if viewModel.canCancel {
                            Button("Cancelar cita") { isChoosingCancellation = true }
                                .disabled(!viewModel.canSave)
                        }
                        if viewModel.canDelete {
                            Button("Eliminar cita", role: .destructive) { isConfirmingDelete = true }
                        }
                    }
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
        .confirmationDialog(
            "¿Eliminar esta cita?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                if viewModel.delete() {
                    onDelete()
                    dismiss()
                }
            }
            Button("Volver", role: .cancel) {}
        } message: {
            Text("Esta acción no se puede deshacer.")
        }
        .confirmationDialog(
            "¿La cancelación está justificada?",
            isPresented: $isChoosingCancellation,
            titleVisibility: .visible
        ) {
            Button("Justificada (no se cobra)") { cancel(.justified) }
            Button("Sin justificar (se cobra)") { cancel(.unjustified) }
            Button("Volver", role: .cancel) {}
        }
        .task {
            viewModel.loadClients()
        }
    }
}

private extension AppointmentFormView {
    func cancel(_ kind: CancellationKind) {
        if viewModel.cancel(kind: kind) {
            onSave()
            dismiss()
        }
    }
}

#Preview {
    AppointmentFormView(onSave: {})
}
