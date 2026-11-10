import SwiftUI

struct ClientFormView: View {
    @State private var viewModel: ClientFormViewModel
    @Environment(\.dismiss) private var dismiss
    private let onSave: () -> Void

    init(client: Client? = nil, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: ClientFormViewModel(client: client))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos fiscales") {
                    TextField("Nombre o razón social", text: $viewModel.name)
                    TextField("NIF / CIF", text: $viewModel.taxID)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }

                Section("Dirección de facturación") {
                    TextField("Calle", text: $viewModel.street)
                    TextField("Código postal", text: $viewModel.postalCode)
                        .keyboardType(.numberPad)
                    TextField("Ciudad", text: $viewModel.city)
                    TextField("Provincia", text: $viewModel.province)
                }

                Section("Contacto") {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Teléfono", text: $viewModel.phone)
                        .keyboardType(.phonePad)
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
    }
}

#Preview {
    ClientFormView(onSave: {})
}
