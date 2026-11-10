import SwiftUI

struct IssuerProfileFormView: View {
    @State private var viewModel = IssuerProfileFormViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre o razón social", text: $viewModel.name)
                    TextField("NIF / CIF", text: $viewModel.taxID)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                } header: {
                    Text("Mis datos fiscales")
                } footer: {
                    Text("Aparecen como emisor en tus ingresos y como destinatario en tus gastos.")
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Mis datos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if viewModel.save() { dismiss() }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .task {
            viewModel.load()
        }
    }
}

#Preview {
    IssuerProfileFormView()
}
